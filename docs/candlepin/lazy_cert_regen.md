---
layout: default
categories: design
title: Lazy Certificate Regeneration
---
{% include toc.md %}

# Lazy Certificate Regeneration
To prevent both performance bottlenecks, and invalidating distributor
certificates who do not know they need to check back in for an updated
manifest, we will change Candlepin to flag certificates as "dirty", and perform
the regeneration on their next check-in or manifest generation.

# Design
There are a few ways certificate regeneration can be triggered:

1. PUT /owners/{key}/subscriptions: Refresh pools (if certain things change):
   1. product name/attributes changed: lazy revocation and regeneration ok
      here.
   1. provided products are added/removed: lazy revocation and regeneration ok
      here.
      * NOTE: we do not regenerate on content set changes, we do for provided
        product changes, but not just content sets within one of those
        provided products. We do not store content data locally in some
        deployments so there's nothing to compare against to see if anything
        changed. Most likely this will be triggered by the content provider
        using the regenerate for product ID API call discussed below.
   1. subscription dates changed: lazy regeneration ok.
   1. subscription was revoked: immediate revocation (no regeneration).
   1. subscription quantity reduced and we are now overconsuming: immediate
      revocation and regeneration. This will only trigger if our code has to
      alter the quantity on an entitlement with a quantity. This is effectively
      the only case where lazy regeneration is not ok.
1. PUT /entitlements/product/{productId}: Regenerate all certificates providing
   a given product. 
   * Can be used by the content provider when they make changes to a product or
     it's content. Doesn't matter what changed, we don't really know, but we
     can rest assured it wasn't anyone losing their subscription access. As
     such lazy revocation + regeneration is ok here.
1. PUT /consumers/{uuid}/certificates: Regenerate everything for a given
   consumer.
   * Lazy revocation + regeneration ok here as well.
1. POST /environments/{envId}/content and DEL /environments/{envId}/content:
   Environment content promotion or demotion
   * If configured for environments, whenever content is promoted/demoted to an
     environment, we mass regenerate for those consumers. 
   * Lazy revocation + regeneration is excellent here as it eliminates a pretty
     severe performance bottleneck, if an admin were promotion/demoting a few
     content sets, certs would not only get regenerated once on the next
     check-in, and the actual promotion/demotion becomes much quicker.

To implement we will add a dirty flag to entitlements, which signals that the
certificates for that entitlement should be regenerated the next time a
consumer checks in or generates a manifest.

Lazy regeneration implies lazy revocation, we want to take a tolerant approach
for invalidating the certificates particularly for manifest consumer types, and
offline systems. As such the revocation should only happen at the time the
certificate is regenerated.

The only exception to lazy regeneration is noted above, if a subscription
quantity has decreased, and we are now overconsuming, if an entitlement is
being regenerated to reduce it's quantity (i.e. an entitlement with quantity >
1), that certificate will be immediately revoked and regenerated.

The API calls which can trigger certificate regeneration will all support a new
optional query parameter *lazy_regen* which will default to true. If explicitly
set to false, we will immediately revoke and regenerate as we do today. This
allows the content provider the option in case something urgent needs to be
done and the certificates must be regenerated. Lazy regeneration however, will
be the default behavior.

# Tasks
1. Add a "dirty" column to cp_entitlement table. 
   * Default to false. 
   * Include upgrade script.
1. Modify `CandlepinPoolManager` certificate regeneration methods.
   * public void regenerateCertificatesOf(Iterable<Entitlement> iterable) is the most important one, but several others call this. 
   * Ideally re-use the same methods both when initiating lazy regeneration, and when actually regeneration, just change behaviour based on the lazy_regen flag.
1. Modify API resource methods to initiate lazy revocation.
   * Include *lazy_regen* query parameter, default to true, but if false, revoke and regenerate immediately. (just like we do today)
   * PUT /owners/{key}/subscriptions
     * Immediate revoke is subscription was removed entirely.
     * Immediate revoke and regenerate if quantity changed, we are over consuming, and reducing the quantity on an entitlement. (Look to `CandlepinPoolManager.deleteExcessEntitlements`)
      * NOTE: Need to be careful here, these entitlements will have to be handled separately so the regenerate methods know not to use lazy.
      * NOTE: Immediate revoke must be immediate, but the certificate can be regenerated immediately or lazily, whichever turns out to be the cleanest to implement in the code.
     * Lazy revocation otherwise. (unless query param is set to false)
   * PUT /entitlements/product/{productId}
     * Lazy regeneration unless query param is set to false.
   * PUT /consumers/{uuid}/certificates
     * Lazy regeneration unless query param is set to false.
   * POST /environments/{envId}/content and DEL /environments/{envId}/content
     * Lazy regeneration unless query param is set to false.
1. Modify API resource methods to perform lazy revocation.
   * If any of the entitlements involved have their dirty flag set to true, regenerate the certificates, and return those instead.
   * Be sure to test to make sure hibernate gets the new data, never the old.
   * All of these calls should pass through one method which does the dirty flag checking + regeneration.
   * Hook up to:
     1. GET /consumers/{uuid}/export (manifest export)
     1. GET /consumers/{uuid}/entitlements
     1. GET /consumers/{uuid}/certificates (both JSON and ZIP calls, which are separate)
     1. GET /consumers/{uuid}/certificates/serials 

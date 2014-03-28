---
layout: default
categories: design
title: Environments Design
---
{% include toc.md %}

# The Problem
Candlepin can easily generate entitlement certs with /$org/$env/content URLs
when that content is not available in pulp.

Examples:

* System binds to a subscription which has not yet had (all of) it's content promoted to the system's environment.
* Org 1 imports a manifest with product P, later on org 2 imports a manifest
  with product P, but P now has new content sets from Red Hat. Org 1's
  entitlements would all get regenerated, go out to client systems, all of whom
  would no longer be able to use yum at all because the content hasn't been
  promoted to their environments in org 1.

# Complicating Factors
1. Yum stops working entirely if one of your repo's has a URL that is not reachable.
1. Content sets are promoted individually, so only some of the content may be promoted to an environment.
1. Content sets may *not* have been promoted to an environment at all.

# Design Proposal
Essentially Candlepin must generate entitlement certificate with accurate
content sets , so we must teach Candlepin about environments. There will be an
"environment lookaside" for product content, which will clarify exactly what
content exists in the consumer's environment.

Multi-org imports will not stomp on each other's data. Admins will see new
content coming available as a result of another org's import, but the content
will have to be explicitly promoted to their environments before anything would
actually change. We have data available to show to admins easily that certain
content sets have not been promoted to their environments, so they can easily
rectify the problem.

## Assumptions
1. Moving a consumer to a new environment is not currently supported and will be dealt with when the time comes.
1. If an arch is blacklisted and thus not prompted to an environment, any system which tries to use content for that arch will end up with yum breaking.
1. We will allow entitlements to be granted (for now) even if none of their content has been promoted to the consumer's environment. The result will be an entitlement cert with no content sets.
1. For now, subscriptions will be available in any environment, even if none of their content has been promoted to that environment. This will be dealt with separately.

# Tasks
1. Add an Environment model.
   1. Remains unused and empty in hosted.
   1. Stores org and environment ID, possibly environment name but that would need to be kept in sync if it changed. (and name may not be needed)
   1. Assumes environment ID is what goes into the content URL and would match Katello.
1. Add Environment REST API calls.
   1. Super admin only.
   1. At least POST GET DELETE.
1. Add an EnvironmentContent model.
   1. This represents the "promotion" of one content set/repo into an environment.
   1. Stores only the environment, and the content, product is irrelevant here. (multiple products could share that content, all we care is that the content was promoted to the environment, after which it is available for any subscriptions that want to use it)
   1. Also store an override for enabled/disabled. This will allow deployments
      where the RHEL optional repo is actually enabled by default, if org
      admins would prefer.  How the promotion will affect the entitlement certs
      already generated for the environment? Good point, we will need to regen some
      certs when content promoted. (assuming we allow entitlements to be granted if
      not all of the content is available in environment already, see below)
1. Add EnvironmentContent REST API.
   1. Org-admin security.
1. When generating entitlement certs, check if the consumer is in an environment.
   1. If so, look for environment specific content to use for the product in
      question. If none is found, fail, as the content is not available.
   1. If consumer is not in an environment, use the default product content.
      (this is what will happen in hosted as it works today)
1. When content is promoted/demoted to/from an environment, regenerate all relevant entitlement certificates.
   1. Lookup entitlements for consumers in that environment.
   1. Find those with products affected by the content promotion.
   1. Regenerate.
1. Deal with existing regenerate due to Product change on import code.
   1. This needs to be dealt with very carefully.
   1. Hosted would never import products so this should not affect them.
   1. If content is added/removed to a product, we no longer want to regenerate all certs, this would happen when that content is actually promoted.
   1. What if existing content changed to a new URL?
   1. What else can change on a product besides content? Would this entail a cert regen for all orgs?

# Katello Tasks
1. Katello: Tell Candlepin when environments are created / destroyed.
1. Katello: Tell Candlepin what environment when consumers register.
1. Katello: Tell Candlepin when a consumer moves to a new environment.
1. Katello: Tell Candlepin when content is promoted or demoted.
   1. This needs to be done carefully as there are probably ways that the
     content set Candlepin knows about is only partially promoted. If Katello
     tells Candlepin it's promoted, it will start appearing in entitlement certs,
     which can fail depending on what's promoted and what clients expand the
     $releasever $arch environment variables to.
    
# Questions
1. Are $org and $env still needed? It looks like the above can do away with
   them as Candlepin will now know exactly what content to include and it's
   full URL. We can hopefully implement the above without using these variables,
   meaning the yum performance hit client side goes away, as does with the issue
   this introduces client side where yum must be run as root to look these up on
   the fly.

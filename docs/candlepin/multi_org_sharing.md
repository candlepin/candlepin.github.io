---
title: Multi Org Sharing
---
{% include toc.md %}

# Business Requirements
* An Organization that entitles a hypervisor in one organization can enable another organization to consume entitlements derived from that hypervisor.
* An Organization can share some subset of their entitlements with another organization. If a set of entitlements are shared with another organization they are considered consumed from the perspective of the source organization.
* A source organization may reclaim entitlements at any point it wishes.

# High Level Design
* A new directional relationship is created between organizations. Org A shares with Org B.
 This relationship could be wrapped in a new type of consumer/distributor.
* When host-guest mappings are created they will look across sharing relationship for matches in addition to the source organization.
* A source organization that wishes to share with another organization will create a new type of consumer of type share. The share consumer identifies the sharing org ( the organization it is created in ) and the recipient org ( stored a field on the consumer ). When this consumer consumes a pool in the source organization, the entitlement will represent the sharing from the source organization. The quantity of the entitlement represents the quantity that is shared. In the receiving organization a new pool will be created with a sourceEntitlement set to the entitlement created in the sending organization.
* Auto-attach is blocked at the organization boundary. If a guest is running on a host in another organization it will not be able to force an auto-attach on the host.
* The definition of a product will come from the sending organization if and only if there has been no manifest import to the receiving organization that defines the product

# Minimum Viable Product
* Sharing a pool with infinite quantity is not supported (must specify a positive integer value for shared count), unless the pool is host restricted.
* No reporting of usage back to the sending organization.

# Development Design

## Conventions
For the purposes of this document, OrgA will always be the source of the share and OrgB the recipient of the share.

## Objects and Relationships
* A share is created in OrgA by creating a consumer of ConsumerType “share”. That consumer is then entitled from the target pool and the entitlement quantity is set to the amount of subscriptions that OrgA wishes to share. Consumers of type “share” will have an attribute (recipientOwnerKey ) reflecting the organization that is receiving the shares. To create a share, a user creates a Consumer of type “share” and binds it to a pool with the quantity they wish to share. When the entitlement, EntitlementS, is created, it will in turn create a share derived pool, PoolD, in OrgB. If the pool being shared is a host-restricted pool, the derived pool should have the same restriction and additionally Candlepin will need to create a temporary guest pool in OrgB.

* Sharing a share or anything derived from a share will be expressly forbidden (e.g. share derived pools will not be eligible for sharing) due to the potential for circular shares and the additional implementation complexity.

* Note that host-restricted pools should also allow binding from share consumer types.

* Share consumers cannot be created with activation keys. Shared consumers should not create stack derived pools. Share consumers are not bound by multi-entitlement restrictions on a product. I.e. you can bind the same pool to be shared multiple times.

## Pool Types and Sharing
Candlepin has a variety of types that pools can fall into. The following list will describe the behavior Candlepin should take when a pool of a particular type is bound to a share consumer:

* Normal: binding should be allowed on these pools
* Entitlement derived: binding to these pools should be allowed, but the share binding process should never create entitlement derived pools. Any created entitlement derived pools should be created under OrgB instead.
* Stack derived: the requirements should be identical to the entitlement derived requirements.
* Unmapped guest: Unmapped guest pools should not be bound to a share consumer. The correct procedure is to instead, bind a host-restricted pool to the share consumer and Candlepin should then create the unmapped guest pools underneath OrgB
* Bonus: These pools are created during a manifest import. Share consumers should be allowed to bind to them.
* Development: these pools should not be bound to a share consumer.

## Pool Considerations
* Since we are now tracking quantities exported, we will now also track the quantity of a pool that is shared on a field on a pool called “shared”, so the total quantity of a pool that is consumed is the sum of quantity exported, shared, and the rest of quantity consumed by non distributors, non shares.

## Product Considerations - (to be updated soon).
When PoolD is created, Candlepin will need to ensure that the product information used by PoolD is populated into OrgB. In other words, if OrgA shared a product, that product must be linked into OrgB when the share is created. There are several scenarios that can occur here:

* The product exists in OrgA but not OrgB: the product should be linked into OrgB. Additionally, the OrgB link should be marked with an attribute that it was created from a share.
* The product exists in both OrgA and OrgB:
  * The products are identical: no action needs to be taken. Since the OrgA and OrgB products are simply a link to the same product definition any update to the product will transparently appear in OrgB.
  * The products are different:
    * If the product in OrgB is marked as a share: the product link in OrgB should be redirected to OrgA’s product. This case should ideally not happen. Precautions should be taken to ensure a share remains pointed to the same product as the OrgA product.
    * If the product in OrgB was created via a manifest import: PoolD will use the product as defined in OrgB.

## Import considerations - (to be updated soon).
* We must also consider the behavior that will occur during a manifest import that changes the product being shared.
  * Manifest import in OrgA: if and only if the product is marked as shared in OrgB, the product should be updated transparently.
  * Manifest import in OrgB: if the product being imported redefines a product marked as shared already in OrgB, the import should create the product according to the manifest and link OrgB to the new product and remove the “shared” marker. Candlepin should also log a message or send an event that Katello can display alerting the administration to the divergence between the two products. i.e. OrgB will no longer be receiving transparent product updates. If OrgB’s new manifest alters OrgB such that the product is no longer referenced, OrgB’s share derived pool will still be referencing that product. In such a case, the entitlement should be altered to use OrgA’s version and the now obsolete product should be deleted. In other words, the product for the share derived pool should be reset back to a “shared” product.

* The behaviors described above are the most expedient for users, but also have a high probability of user confusion. Imagine a product already defined in OrgA and OrgB. An administrator for OrgA who creates a share could easily be confused as to why consumers subscribing to the share are getting content not defined on the product they shared from OrgA (since Candlepin is actually using the product that was already defined in OrgB). Or an administrator for OrgB who is used to the shared product updating transparently with OrgA performs a manifest import. One day the administrator from OrgB imports a manifest with the same product and the connection between the products is broken and OrgB mysteriously stops receiving product updates when OrgA performs imports.

* We must make the potential pitfalls obvious and discoverable. We should take care to send messages/events to Katello so that Katello can alert the user to the changed behavior. Additionally, as future work in version 2, we should keep a sharing history that will record when these edge cases are encountered and how they were resolved. This history will provide a permanent record that administrators can consult in case of confusion. The history should contain at a minimum the two organizations involved and the product/versions of a product that are involved. Ideally we would provide information about the differences between two versions of a product if an import creates a product divergence.

## Revocation consideration
* Currently revocation considerations exist on a single axis: consumer creation time. Candlepin is configured by default to revoke entitlements using a first-in-first-out rule (last-in-first-out is the other option). If OrgA imports a manifest that lowers the quantity of the source pool, Candlepin will need to determine which entitlements to revoke and with sharing there is now a new axis to consider: do we favor the sharer or share recipient in any way? For example, if we retain the first-in-first-out approach but always revoke first from the share recipient, then an ordered consumer list of OrgBConsumer, OrgAConsumer1, OrgAConsumer2 would result in the revocation of OrgAConsumer1 if one revocation were performed.

* For the initial release of the sharing functionality, we will eschew these complexities and have Candlepin to continue to consider only the consumer creation time when performing revocations.

* If OrgA imports a manifest that reduces the source pool size, the adjustment to the entitlements already granted will be as follows:
  * Reduce the entitlement quantity for any share consumers using consumer creation LIFO so that any unused units will be removed.
  * Revoke existing requirements using consumer creation LIFO using both OrgA non-share consumers and OrgB consumers. Any OrgB revocations will have an accompanying reduction as per #1.

## Attaching
* Candlepin will also need to factor in the provenance of a pool into the calculations used to “heal” consumers. A shared pool should be discounted in favor of a non-shared pool of the same product when making healing determinations. Since shared pools have more potential for user confusion, they should avoided when a non-shared analog is available. If multiple shared pools are available, they should be ordered using the same heuristics Autoheal uses for normal pools.

## Listing Pools
* Satellite will need to display a list of pools that are available for sharing so that users can select them in the interface.
 The list available pools method when called on a share consumer will need to filter pools that are unavailable to shares (e.g. unmapped guest pools in OrgA).

## Deleting an Organization
* If OrgB is deleted, all derived entitlements are revoked and the “share” ConsumerType and share pool in OrgA are deleted.
* If OrgA is deleted, if there is a share with consumers drawing from the share derived pool, Candlepin should refuse to delete the organization. There should be an override flag however (much like with manifest import) that would all OrgA to be deleted. In this case, all entitlements from the share derived pool in OrgB will be revoked before OrgA is deleted. To delete OrgA without requiring an override, OrgA would need to delete the “share” consumer and thus all entitlements derived from that share would be revoked.

## Share REST APIs
* All share specific APIs that surfaces the most common share operations (list org shares, create share, bind to share) under a new resource (owners/{id}/shares or the like). These API methods would be simple pass throughs that delegate to the existing resource methods that implement sharing. These new methods would exist to reduce complexity for the benefit of users.


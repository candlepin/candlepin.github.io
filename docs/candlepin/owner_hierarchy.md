---
layout: default
categories: design
title: Owner Hierarchy
---
{% include toc.md %}

# Requirements
* Support a Candlepin deployment where Owners can be top-level, importing their own data from an authoritative Candlepin instance.
* Each top-level owner can create sub-owners.
* Top-level owner can split their subscriptions assigning separate quantities to their sub-owners for use.
* One on-site Candlepin may be hosting multiple disjoint top-level owners, each with their own subscriptions in an upstream hosted Candlepin instance.

# Design
* Implement a simple owner hierarchy where an owner can have an optional link
  to a parent owner. (Owner.getParentOwner())
* Implement a simple pool hierarchy to be used when delegating entitlements to
  sub-owners. (Pool.getParentPool())
  * Top level owner admins would have the ability to split their pools and
    create a sub-pool in the other owners. 
  * Parent pool's quantity would be reduced accordingly.
  * In many ways this is just focusing on what we want, we have a pool in the
    top level org, we want to split it and create a related pool in the
    sub-org.
  * Refresh pools will be the most challenging aspect of this. 
    * When refreshing a pool from a subscription, we cannot just blindly copy
      the quantity onto the associated pool because that pool could have
      reduced it's quantity and allocated some to a sub-pool. 
    * If that quantity were reduced we have a messy situation and need to
      determine not just how to clean up outstanding entitlements, but also to
      clean up outstanding sub-pools (possibly multiple levels deep) and their
      entitlements as well. 
    * We have not yet solved reduced quantity in Candlepin anywhere, we just
      let the pool go out of compliance and plan a batch job to determine what
      to do. (it just now will be a little more complex)
  * When a subscription disappears, we currently delete the pool and thus all
    related entitlements. This process will continue, only now deletion of a
    pool will cascade to all sub-pools in sub-owners.

##Problems
* Our security settings are going to throw a fit. We automatically filter out
  objects in queries and block CRUD operations across owners. These will either
  need to be modified to allow if within an owner hierarchy, or will have to be
  thrown out entirely. 

# Other (less awesome) Ideas

## Re-use Import Export
This was the first option to come to mind but I think it quickly begins to look
infeasible and messy. For one, much of the data in an export is already there
(products / consumer types / rules), only the Entitlement importer would be
re-usable. If so, then the process would become an upstream subscription
becomes an upstream pool, an on-site Candlepin is deployed and registered as an
upstream consumer, who then binds and obtains entitlments with a quantity. The
export is generated and then imported on-site, those entitlements now translate
into a new subscription and then a pool on-site.

If we were to continue with this, the whole process would be repeated for each
sub-org leading to a proliferation of subscriptions and pools, all of which
need to be kept in sync. This seems like a recipe for problems when considering
the worst case scenario where a subscription is reduced. It's also arguably a
mis-use of the Subscription, at this point it isn't really a Subscription, and
perhaps we should only be dealing with pools during this process.

## Re-use Sub-pools
These are the pools which have a source entitlement link, intended for things
like developer licenses a person consumes and then starts using a sub-pool for
their systems.

To re-use this, sub-owners would require a consumer in the top level org. If
this were in place, they could bind and create entitlements with a quantity,
and then a sub-pool would be created in the sub-org which links to the parent
entitlement.

I consider this a promising possibility, but still more complicated than it
needs to be. All we really want is a sub-owner with a sub-pool, requiring that
sub-owner to be represented by a consumer and bind (generating entitlement
certificates) complicates the process and adds more moving parts to keep track
of, particularly when time comes to sync up with the upstream subscription. IMO
the simpler the better, given the complexity we're headed for.

---
layout: default
title: How Subscriptions Work
---
{% include toc.md %}

Candlepin uses Subscriptions to provide access to content. The system for
getting access to content via these subscriptions is described below.

# Products

## Engineering Products
* The low level products which provide actual content repos.
* Always have numeric IDs. Content is packed into an entitlement cert as an OID which must be numeric.
* These can appear as "installed" product certs on a system in /etc/pki/product. (aka installed products)
* Does not normally carry product attributes, or rather Candlepin does not check their attributes.

## Marketing Products
* The top level product associated to a subscription. (each subscription has only one)
* Carries all the attributes which control the business logic in Candlepin with
  regard to how that subscription can be used, and what will happen when it is.
* Generally has an alpha-numeric ID.
* Carries no content.
* Will never appear as an installed/engineering product.

# Subscriptions
* Generally represents what a customer has purchased.
* In the case of an on-site server which has created a distributor in the customer portal, assigned it entitlements, and exported/imported a manifest, one Subscription object will be created per entitlement given to the distributor. (even if they originate from the same pool/subscription)
* Maps to one marketing product which defines all the business logic.
* Provides potentially many engineering products for the content this subscription grants access too.
* The subscription *may* live in a foreign system accessed through an adapter.
  (hosted) We also provide a default adapter which allows them to be stored in
  Candlepin itself.

# Pool
* In many ways, this is almost a copy of the Subscription, but they can differ slightly in some situations.
  * Multipliers may cause the quantity of the subscription to be multiplied on the pool.
  * Some subscription marketing products carry attributes that tell Candlepin to create two pools.
  * Some pools are created as a result of a bind/attach/entitlement, these are commonly called sub-pools.
* Stores a copy of all the provided products from the subscription. (both for speed and for detecting when something changed)
* Stores a copy of all the attributes from the marketing product. (both for speed and for detecting when something changed)


## Types of Pools

Depending on the attributes of the subscription's marketing product, a subscription may result in the creation of one or more pools.

1. Master Pool
  * One of these will always be created for any subscription and this can be considered the parent or "main" pool.
  * subscriptionsubkey = master
1. Derived Pool
  * Created as the result of an entitlement to a pool with a virt_limit attribute.
  * If the pool has a stacking_id, see Stack Derived Pool below.
  * When a host system binds to a pool with virt_limit, a derived pool is created for guests *on that host*.
  * Derived pool will have a pool attribute: requires_host = candlepin host consumer UUID
  * Access to this pool will be restricted to guests who have been reported as running on that host by virt-who.
  * subscriptionsubkey = derived
1. Stack Derived Pool
  * Similar to a Derived Pool, only when stacked there is a business requirement that only one sub-pool ever exists for that stack for a given consumer.
  * When a host first binds to a pool with a given stack ID, a stack derived pool is created.
  * On subsequent binds to pools with that same stack ID, the stack derived pool is updated to have merged characteristics of all the pools in the stack. *insert link here*
  * subscriptionsubkey = derived
1. Virt Bonus Pool
  * A legacy type of subscription which can exist only in hosted and is no longer used on new SKUs.
  * Triggered in hosted when marketing SKU specifies a virt_limit attribute but does *not* have host_limited = true.
  * Pool is created during refresh pools when subscription is first seen, as opposed to as the result of an entitlement as most other derived pools are.
  * subscriptionsubkey = derived

# Entitlement
* Represents the consumption of a Pool for a given consumer.
* Can have a quantity, a consumer system may require a greater quantity than just 1.
* Carries the certificate sent to clients. Grants access to all of the provided products from the pool.
* Can be revoked returning the used quantity back to the pool.

# Auto-attach
* A major part of Candlepin is the auto-attach routine on the server which
  attempts to find the best fit of available subscriptions to cover the
  consumer's installed products.
* Subscriptions will frequently provide access to more product IDs than those
  which are installed. We're simply looking for coverage, i.e. a combination of
  subscriptions which covers everything installed (if possible).
* Rules are quite complex and there are a number of criteria considered to use one combination over another.
* By default runs daily for each system to try to repair anything that is amiss. (aka healing)

# Manual Attach
* Subscriptions can also be consumed manually, even if no engineering product cert is installed on the system.
  * This entitlement still counts as in use, so the quantity is debited from the pool, and the attributes on the marketing product are still enforced.
  * Sometimes the product cert will appear on the system after packages are installed, but this is not guaranteed, and it's best to consider that the subscription is in use at attach time, not at yum install time.

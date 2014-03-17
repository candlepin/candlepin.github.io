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

# Subscription
* Generally represents what a customer has purchased.
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
* Copies all of the provided products from the subscription.

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

---
title: Subscription Types
---
{% include toc.md %}

Candlepin supports a number of different subscription types which are defined by the attributes on the marketing/SKU product on the subscription. You can view the list of [product attributes](product_attributes.html), this document will outline at a higher level how they can be combined to create the various major types of subscriptions Candlepin supports.

## Plain

A subscription lacking any of the relevant attributes is very simple, any system requires a quantity of 1 to be covered.

## Stacked

Stacked subscriptions require a quantity based on some aspect of the hardware on the system consuming the subscription.

Example product attributes:

 * stacking_id: Some arbitrary string, in practice typically set to the marketing product ID.
 * sockets: 2

This subscription would require quantity 1 for every 2 sockets on the system in question. Sockets are calculated from the cpu.cpu_socket(s) fact on the consumer. An 8 socket system would thus require a quantity of 4 from this subscription to be fully covered.

The stacking_id implies that entitlements from any other pool with that stacking ID could be used to cover the system. If the system required 8, but only 4 were available in two separate pools, the required entitlements could be split across those pools.

CPU socket stacking is by far the most common, but Candlepin also supports stacking on RAM and CPU cores.

## Virt Limit

Virt limit subscriptions are used to entitle a physical host, as well as some quantity of guests running on that specific host.

Example:

 * virt_limit: 4 / unlimited

When a physical host consumes a virt_limit subscription, a sub-pool is created that is only visible/usable by guests who are running on that host. The virt-who utitlity is typically what reports the host/guest mapping information and allows this functionality to work. Revoking the physical host entitlement will result in revoking the sub-pool and all its existing entitlements.

Note that guests can still consume the main pool, provided the product does not also carry the physical_only attribute.

## Instance Based

Instance based subscriptions entitle either 2 virtual guests (regardless of hardware), or one physical socket pair.

Example:

 * sockets: 2
 * stacking_id: Some arbitrary string, in practice typically set to the marketing product ID.
 * instance_multiplier: 2

The instance_multiplier is the key attribute which triggers this behaviour. Because we do not wish to ever show the user fractional quantities consumed from a pool, the instance multiplier results in a pool quantity that is doubled. i.e. purchasing a subscription of quantity 10 results in a pool of size 20. (subscription quantity * instance_multiplier)

A virtual guest will only ever require a quantity of 1 from the pool to be covered.

A physical system will require quantity 2 per socket pair.

The subscriptions cannot be broken down for physical systems if they were to have just 1 socket, that system would still require the minimum quantity of 2.

i.e. A physical system with 8 sockets will require quantity 8 (system sockets / product sockets * instance_multiplier)


## Derived

Derived subscriptions are a variant of virt-limited subscriptions and are actually driven by data on the subscription itself rather than its product attributes. These subscriptions are designed such that the physical host using the main subscription receives different content than its guests.

A derived subscription carries both an additional derived product, and list of derived provided products. When a physical host consumed the main pool it receives the normal product and provided product list. However the sub-pool created for guests on that host will receive the derived product and derived provided products.

This is typically used in hypervisor style subscriptions where the host requires no content, but its guests do.

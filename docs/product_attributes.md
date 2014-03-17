---
layout: default
title: Product Attributes
---
# Product Attributes

| Name | Appears On | Possible Values | Purpose | Notes |
-|-
| arch | product | ALL, x86_64, i686, x390x | A list of architectures which a subscription can be attached to. All is used to denote all architectures. |
| host_limited | product | true, false or \<not present\> | Modifies virt_limit behaviour in hosted to create host restricted sub-pools on bind, rather than the one big bonus pool. |
| instance_multiplier | product | integer | Triggers instance based subscriptions. Multiplies size of the pool, but physical binds will consume entitlements in multiples of this value. |
| management_enabled | product | 1|0 | Denotes if management is enabled. This value is passed down in the certificate. |
| multi-entitlement | product | yes,\<not present\> | If yes, a consumer can attach a subscription for this product more than once. If set to anything else or not present, they can't. |
| pool_derived | pool | true, \<not present\> | Internal attribute, which denotes the pool was created by a rule |
| ram | product | GB of RAM | The amount of RAM subscription can cover. |
| requires_consumer_type | product | consumer type (currently: system, person, domain, candlepin) | Limits the consumer type which a subscription can be attached to. |
| requires_host | pool | Host consumer UUID | Indicates that only guests whose host consumer matches the given UUID can use this subscription.  |
| sockets | product | number of cpu sockets | The number of sockets which a subscription can cover. |
| support_level | product | human readable description of support level | Used to match a usrs preference to make a machine a certain support level. |
| support_type | product | human readable description of support type | Passed down to the certificate. |
| user_license | product | "unlimited", int | Indicates that when an entitlement is granted, a new pool is created of the indicated size, which is only available to consumers registered by the same user account. This is used to model "developer subscriptions"  |
| user_license_product | product | product ID | Indicates what product the new pool should be for in the above scenario. If not specified, the same product is used from the original subscription/pool. |
| variant | product | product variant | This value is passed down to the certificate. |
| version | product | product version | This value is passed down to the certificate. |
| virt_only | product, pool | true, \<not present\> | If true, a susbcription can only be attached to a virtual machine |
| virt_limit | product, pool | number | Indicates a number of guests an subscription includes. This behavior varies depending on whether or not the server is configured for standalone. If in standalone, an entitlement creation will create a sub-pool restricted to only guests on that host. In hosted, a single virt pool is created during refresh pools for floating guests with no restrictions on which host they are on, nor any requirement that the host be registered and subscribed beforehand. |
| stacking_id | product | string | An arbitrary string which creates a functional equivilance across different products. This is used with multi-entitlement to allow combining many subscriptions. |
| warning_period | product | number | The number of days prior to expirey where the client should warn that a subscription will soon expire. |
{:.table-striped .table-bordered}

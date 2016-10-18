---
title: Product and Pool Attributes
---
# Product and Pool Attributes

| Name | Appears On | Possible Values | Passed in Certificate | Purpose | Notes |
-|-
| arch | product | ALL, x86_64, i686, x390x | Yes | A list of architectures for which a subscription can be used. All denotes all architectures. |
| host_limited | product | true, false or \<not present\> | No | Modifies virt_limit behaviour in hosted mode to create a host restricted sub-pool on each host bind, rather than a single bonus pool for all guests. |
| instance_multiplier | product | integer | No | Triggers instance based subscriptions. Multiplies quantity of the pool. Physical binds will consume entitlements by multiples. |
| management_enabled | product | 1 or 0 | Yes | Indicates whether management is enabled. |
| multi-entitlement | product | yes,\<not present\> | No | If yes, a consumer can attach a subscription for this product or a stack of products in a quantity greater than one. |
| physical_only | product | true,\<not present\> | Yes | If true, a subscription may only be attached to a physical machine. |
| pool_derived | pool | true, \<not present\> | No | Internal attribute, which denotes the pool was created by a rule. |
| ram | product | GB of RAM | Yes | The amount of RAM a subscription can cover. |
| requires_consumer_type | product | consumer type (currently: system, person, domain, candlepin) | No | Limits the type of consumer that can use this subscription. |
| requires_host | pool | Host consumer UUID | No | Only guests with a matching host consumer UUID can use this subscription.  |
| sockets | product | number of cpu sockets | Yes | The number of sockets a subscription can cover. |
| support_level | product | human readable description of support level | Yes | Used to match the consumer's service_level for subscription attachment decisions. |
| support_type | product | human readable description of support type | Yes | Subscription information. |
| user_license | product | "unlimited", int | No | Indicates that when an entitlement is granted, a new pool is created of the indicated size, which is only available to consumers registered by the same user account. This is used to model "developer subscriptions"  |
| user_license_product | product | product ID | No | Indicates what product the new pool should be for in the above scenario. If not specified, the same product is used from the original subscription/pool. |
| variant | product | product variant | Yes | Informational |
| version | product | product version | Yes| Informational |
| virt_only | product, pool | true, \<not present\> | Yes | If true, a subscription can only be attached to a virtual machine |
| virt_limit | product, pool | number | No | Indicates the quantity of guest entitlements a subscription includes. The behavior varies depending on server configuration. If in standalone mode, host entitlement creation will spawn a sub-pool restricted to guests on that host. In hosted mode, a single virt pool is created for all guests with no host restrictions. |
| stacking_id | product | string | Yes | An arbitrary string which creates a functional equivalence across different products. Its use leads to a single sub-pool for guests on a single host that have any of the products from the stack installed. Multi-entitlement is optional in conjunction with this attribute and is not mandatory. |
| warning_period | product | number | Yes | The number of days prior to subscription expiry the client should issue warnings. |
{:.table-striped .table-bordered}

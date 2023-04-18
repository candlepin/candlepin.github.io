---
title: Unmapped/Temporary Guest Pool 
---

{% include toc.md %}

This document describes when and with what count temporary guest pools are created, how the count is determined and are temporary pools created only after a hypervisor consumer has consumed 1 or more from the physical pools?


## Below are the modes of the pool creation:  

1. Hosted mode: Pools are created by the refresh pools operation, which relies on an upstream subscription source.
1. Standalone mode: The manifest import operation is used to create pools in Candlepin. Manifest contains all information required to create the subscriptions.

Note: Unmapped guest pools are always created during refresh pools or manifest import operations, and their creation is irrelevant to if a hypervisor consumer has consumed 1 or more from the physical pool. 


## Primary pool is created with quantity:

In hosted, we increase the quantity on the subscription. However, in standalone, we assume this already has happened and the accurate quantity is exported.

Calculation of quantity in Standalone Candlepin:

	quantity  =  primaryPoolQuantity  * productMultiplier

Calculation of quantity in Hosted Candlepin:

	quantity  =  primaryPoolQuantity * productMultiplier
	quantity  =  quantity *  product_Instance_Multiplier
	primaryPoolQuantity  =  quantity	

## Steps performed to create Unmapped Guest pool:

Once the non-custom primary pool is created, current code performs following steps to create temporary guest pool: 
~~~
1. Calculate virt_quantity using following formula:
	(a) if product_virt_limit  =  unlimited, 
		virt_quantity  =  “unlimited”
        (b) if product_virt_limit > 0,
    		virt_quantity  =  product_virt_limit  * primary_pool_quantity
        (c) virt_quantity  =  null
2. If virt_quantity is null then skip temporary guest pool creation process. 
3. If there is any existing bonus/derived pool in pools created with the same subscription of primary pool then skip guest pool creation process. 
4. If Candlepin is running in standalone mode or host limited attribute on product is true then create temporary guest pool by cloning primary pool with virt_quantity value as pool quantity. 
~~~

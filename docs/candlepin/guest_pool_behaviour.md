---
Title: Unmapped/Temporary Guest Pool 
---

## Pools are created in 2 modes listed below:  

1. Hosted mode: Pools are created by the refresh pools operation, which relies on an upstream subscription source.
1. Standalone mode: The manifest import operation is used to create pools in Candlepin. Manifest contains all information required to create the subscriptions.

## Master pool is created with quantity:

In hosted, we increase the quantity on the subscription. However, in standalone, we assume this already has happened and the accurate quantity is exported.

Calculation of quantity in Standalone Candlepin:

	quantity  =  masterPoolQuantity  * productMultiplier

Calculation of quantity in Hosted Candlepin:

	quantity  =  masterPoolQuantity * productMultiplier
	quantity  =  quantity *  product_Instance_Multiplier
	masterPoolQuantity  =  quantity	

## Steps performed to create Unmapped Guest pool:

Once the non-custom master pool is created, current code performs following steps to create temporary guest pool: 
~~~
1. Calculate virt_quanity using following formula:
	(a) if product_virt_limit  =  unlimited, 
		virt_quantity  =  “unlimited”
        (b) if product_virt_limit > 0,
    		virt_quantity  =  product_virt_limit  * master_pool_quantity
        (c) virt_quantity  =  null
2. If virt_quanity is null then skip temporary guest pool creation process. 
3. If there is any existing bonus/derived pool in pools created with the same subscription of master pool then skip guest pool creation process. 
4. If Candlepin is running in standalone mode or host limited attribute on product is true then create temporary guest pool by cloning master pool with virt_quanity value as pool quantity. 
~~~


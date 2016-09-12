---
title: Storage Band Subscription
---
{% include toc.md %}

# Storage Band Subscription Implementation

## Storage Band (Ceph) SKU

The SKU (marketing product) should be defined such that it makes use of the product multiplier in order to provide enough entitlements to cover the total capacity of all nodes in TB. Each entitlement will equate to 1TB of coverage and marketing products will use the multiplier such that "sub_quantity_purchased x multiplier" will yield pool quantity (total capacity in TB).


Consider the following SKU definition (note that multiplier is NOT a product attribute) and a customer who bought 1 subscription.

    multiplier: 512
    stacking_id: product_stack_id
    mutli-entitlement: yes
    storage_band: 1


    pool_quantity = sub_qty_bought * multiplier
                  = 1 * 512
                  = 512


The resulting pool will have a quantity of 512, which can cover 512TB of storage (across multiple nodes/systems).



**NOTE:** The “storage_band” attribute enables storage counting. It is important to note that this is NOT an on/off switch. To the rules framework, this is the value of a single entitlement (or how the entitlement will be evaluated for coverage) and it will be used to determine coverage of a consumer. For CEPH, this will equate to 1TB per entitlement.  Thus the user must “stack” on enough 1 TB entitlements to cover the storage capacity on the system assigned to Ceph.


## Generating Status (Rules)

The rules will calculate a system's coverage based on a **band.storage.usage** fact and will compare this to 
**entitlement_quantity * storage_band**. Because stacking will be configured, coverage will be calculated based on the 
sum of the above calculation for all entitlements in the stack.

Consider a system that is using 128TB: 

    band.storage.usage: 128

Coverage will be calculated by considering each entitlement as 1TB of coverage, as follows:

*  a quantity of 128 entitlements will cover the system (green).
*  2+ stacked entitlements whose quantities total >= 128 (green)
*  quantity < 128 entitlements will partially cover the system (yellow)
*  2+ stacked entitlements whose quantities total < 128 (yellow)
*  no entitlements (red)

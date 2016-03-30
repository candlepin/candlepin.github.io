---
title: Storage Band Subscription
---
{% include toc.md %}

# Storage Band Subscription Implementation

These are implementation details of [Storage Band Subscription Type](subscription_types.html)

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



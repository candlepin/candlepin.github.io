---
title: Pool Types
---
{% include toc.md %}

### Types of Pools

When a subscription object is imported, one or more pools will be created, depending on the attributes of its marketing product.

1. Master Pool
  * At least one subscription pool will always be created for any subscription. That Pool is called Master Pool
1. Bonus Pool
  * Created as the result of an consumption of a pool with a virt_limit attribute (the marketing product of the pool having virt_limit attribute)..
  * If the marketing product of a pool has a stacking_id, see Stack Bonus Pool below
  * When a host system binds to a pool with virt_limit, a bonus pool is created for guests *on that host*. Bonus pool will have a pool attribute: requires_host = candlepin host consumer UUID. Access to this pool will be restricted to guests who have been reported as running on that host by virt-who.
1. Stack Bonus Pool
  * Similar to a Bonus Pool, only when stacked there is a business requirement that only one bonus pool ever exists for that stack for a given consumer.
  * When a host first binds to a pool with a given stack ID, a stack derived pool is created.
  * On subsequent binds to pools with that same stack ID, the stack bonus pool is updated to have merged characteristics of all the pools in the stack
1. Unmapped Bonus Pool
  * To help customers struggling with timing issues between when a guest is created and tries to subscribe, and when virt-who reports the host to guest mapping (unlocking the pools for that guest), unmapped bonus pools were added.
  * These pools are only usable by guest consumers who are less than 24 hours old, and who have not yet been linked to any host.
  * Entitlements will only be valid for 24h.
  * As soon as virt-who reports the host guest mapping any entitlements to unmapped bonus pools are revoked.
    * An auto-bind is then performed on the guest, which includes attempting to attach any pools to the host which will unlock derived sub-pools for something the guest needs.
1. Virt Bonus Pool
  * A legacy type of subscription which can exist only in hosted and is no longer used on new SKUs.
  * Triggered in hosted when marketing SKU specifies a virt_limit attribute but does *not* have host_limited = true.
  * Pool is created during refresh pools when subscription is first seen, as opposed to as the result of an entitlement as most other derived pools are.

#### Derived Products

Pools can also carry a derived marketing product and derived provided marketing products. These derived products are used in virtualized environment to accomodate scenarios where a host is intended to get access to different (or no) content than the guests. The  master pool will use the marketing product and provided products on the subscription. However any bonus pools or unmapped bonus pools will flip to use the derived marketing product and derived provided products. 


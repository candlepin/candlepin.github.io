---
title: Pre entitlement rules checks
---
# Pre entitlement rules checks

The following are the checks candlepin performs based on consumer facts and pool attributes to decide if it is a valid bind:

 * **do_pre_global**:
    * for manifest consumers, if product has a derived product, only allow the bind if consumer has derived_product capability
    * multi-entitlement checks. if the pool does not have a multi-entitlement attribute:
       * verify the consumer does not already have an entitlemnt of the same pool
       * verify the quantity requested is not more than one
    * if required consumer type is not specified, consumer type should be either system or hypervisor.
    * if the pool is restricted to username, ensure it matches the request
 * **do_pre_virt_only**:
    * manifests cant consume virt pools if they are also pool_derived.
    * non guests and non manifests cant consume virt pools.
 * **do_pre_physical_only**:
    * guests ( unless they are distributors ) cant consume physical only pools
 * **do_pre_unmapped_guests_only**:
    * virtual guests cannot use unmapped guest pool if we know which host it belongs to.
    * virtual guests cannot use unmapped guest pool if they are new newly registered.
    * virtual guests cannot bind future unmapped guest pools
 * **do_pre_requires_host**:
    * manifests cant consume required_host pools
    * if consumer does not have a virt.uuid fact, and the pool has a requires_host, do not allow bind.
    * the pool owner must match the host of the virtual guest ( identified by the requires_host pool attribute ).
 * **do_pre_requires_consumer**:
    * manifests cant consume required_consumer pools
    * the pool owner must match the consumer uuid (identified by the requires_consumer pool attribute).
 * **do_pre_requires_consumer_type**:
    * if a consumer_type attribute is on the pool, ensure it matches that of the consumer requesting the bind
 * **do_pre_vcpu**:
   * for non manifest guests, if consumer has a cores attribute and the pool is not stacked, make sure the pool has enough cores.
 * **do_pre_architecture**:
   * for non manifests, if pool requires arch, make sure consumer belongs to the same arch.
 * **do_pre_sockets**:
   * for non manifests and non guests, if consumer has a socket fact and pool is not stacked, ensure the pool provides enough sockets.
 * **do_pre_cores**:
   * for non manifest non guests, if consumers has a cores fact, and pool is not stacked, ensure consumer has enough cores.
   * for manifest consumers, make sure manfiest consumer has cores capability.
 * **do_pre_ram**:
   * for non manifests, if pool is non stacking, ensure pool has enough ram.
   * for manifests, ensure manifest has ram capability
 * **do_pre_storage_band**:
   * for non manifests, if pool is non stacking, ensure pool has enough storage
   * for manifests, ensure manifest has storage capability
* **do_pre_instance_multiplier**:
   * for non manifests, non guests, for direct binds, verify quantity is divisible by pool's instance multiplier.
   * verify manfest consumers have instance multiplier capability.

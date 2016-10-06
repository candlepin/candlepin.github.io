---
title: Autobind
---
{% include toc.md %}

# Autobind
Autobind is designed to join the correct quantity of the correct pools with a
consumer in order to fully provide as many products as possible.

I have made a few changes from the old approach.  For example, the new
algorithm will never suggest pools that will result in partial coverage.

## The Algorithm

### Validate Pools
The rules.js is passed a context, which contains important data such as the
consumer, service level, pools available, products to cover, and a compliance
status at the time healing will take place

We can safely remove all pools from this list that:

* do not match the service level override or service level of the consumer.
* require an architecture that does not match the consumer, as that will never make a product fully compliant.
* are virtual if the consumer is not a guest.
* have 0 quantity (or quantity \< instance_multiplier if the system is physical.)
* are not valid (date) at the time of the check.

During validation, pools that do not allow multi-entitlement (stacking of a
single entitlement) have their available quantity set to 1, so that they can be
considered the same way as multi-entitlement pools.

### Get Attached Entitlements
Next we must get the list of attached entitlements, which are used to complete
partial stacks, or let us know if a stack cannot be completed.
These entitlements are added to the list of entitlements whenever a compliance
check is run.

### Get Installed Products
The list of installed products comes directly from the context, but we filter
out products that are already found in the compliance status
"compliantProducts"

### Build Entitlement Groups
Entitlement group objects provide a way to treat stacks and single entitlements interchangeably.  They consume pools and provide products.
Pools are put into entitlement groups by stacking_id, whereas single entitlements are 1:1 with entitlement groups.

### Validate Entitlement Groups
Once we have built all of the entitlement groups, we must validate them to make
sure it is possible to make them cover our system.  If a group is invalid, it
is discarded, because it cannot be useful for the system.

If the entitlement group is not a stack, we can check overall validity based on
whether the single pool (max available quantity) is compliant.

Otherwise, in the stacked case, it is a little bit more difficult.  In some
situations, a partial stack can be made compliant by removing entitlements.  For
example, if I have a stack of 4 socket entitlements, and add one entitlement
that covers 1GB of ram, my entire stack will be partial.  We first need to
check if the stack, with already-attached subscriptions, is compliant.  If it
is, we can say the group is valid. However if it is not compliant, we must
remove all pools that enforce stackable attributes that have caused problems
(taken from compliance reason keys) After removing those pools, we run a final
compliance check, the result of which is the groups validity.

### Select Best Entitlement Groups
Firstly, we try to complete partial stacks, if possible.  If there is a stack
group with the same stack_id, it is possible (because it passed validation)

This uses a greedy approach, rather than enumeration.
While a valid group exists that covers a non-covered product, add the group
that covers the most products to "best groups"

* Ties are broken by
1. number of host specific pools
1. number of virt_only pools
1. prefer unstackable entitlements

This ensures that we are covering every product that is possible to cover, with
no excessive groups (you cannot remove any stack or unstackable entitlement and
remain compliant)

### Remove extra attributes
For each entitlement group, attempt to remove all pools that enforce each
combination of attributes.  Use the group of pools that has the most virt_only
pools if the consumer is a guest, otherwise the set with the fewest pools.
This prevents us from attaching "parallel" stacks, where we essentially have a
compliant sockets stack, and a compliant cores stack.

### Prune Pools
Remove all pools from the group that are not required to make the stack/product
fully compliant.  This can be skipped for non-stack groups, because they only
have 1 pool, and at this point we know the group is required to cover a
product.  We sort the pools based on priority, which is calculated based on
whether or not the pool is virt_only/requires_host, so those are preserved as
long as possible Try removing one pool at a time, and check compliance with
everything else (that has not been removed) at max quantity.  If the stack is
compliant and covers all the same products, disregard the removed pool,
otherwise add it back.

### Select Pool Quantity
This is very similar to prune pools, except we know that every pool is
necessary, and we want the minimum quantity per pool.  loop over pools again,
adjusting quantity to consume, starting at the minimum increment, up to max
available, until the stack is compliant.  return a map of pool id to pool
quantity for candlepin to interpret.

## Accomodating Guests
When a guest attempts to autobind, the host will first attempt to autobind, with some significant changes:

1. The host will be handed the guests list of installed products, and attempt to autobind with these
  * Products are removed from this list if they're already provided by other virt-only pools
1. The host will be restricted to using subscriptions that will create bonus pools
  * Right now this means only pools with the virt_limit attribute with a
       value not equal to "0"

TODO: Do we need to consider quantity here? If there is already a virt_only
pool, but it's fully used, it would be nice to add more. However whatever we
add *must* not be stacked with what's already there, otherwise we won't
actually be adding any new guest entitlements. (due to one sub-pool per stack)
First draft, it is probably best to ignore quantity / usage, if there's a
virt_only pool, we've done what we can. If it's fully consumed, this code will
not help the guest out.

Caveats:

  1. The quantity the guest will need is not considered, we only attempt to get
     a pool available. Usually the guest just needs one. But with issues like
     one sub-pool per stack, trying to add more entitlements becomes noticably
     more difficult.

## Disabling Autobind For An Owner
_This feature is available in both candlepin-0.9.54.11+ and candlepin-2.0.20+_

Candlepin allows the disabling autobind, on a per Owner basis, to accomodate entitlement stability
for Consumers of an Owner/Organisation during subscription renewals and/or other maintenance.

In many circumstances, Candlepin's autobind functionality is not the greatest at selecting the most
appropriate entitlements to attach to a consumer. This is in part to the vast number of combinations
of entitlements that can be selected to cover the needs of a consumer and make it valid. Often times,
this can lead to a consumer being given entitlements that may not make sense for a customer's deployment,
leaving it up to and admin to manually fix them.

Providing the ability to disable autobind at an owner level will stabilize consumer entitlement change
temporarily, while maintenance such as renewals, can be performed.

### Updating The Owner Setting
Autobind can be enabled/disabled for an Owner by modifying its autobindDisabled field via the
update owner API.

```
PUT /owners/:owner_key
```

For example:

```bash
$ curl -X PUT -k -u username:password -d '{"autobindDisabled":true}' -H "Content-Type: application/json" https://localhost:8443/candlepin/owners/your_owner_key
```

### Impact On Candlepin Features

#### Consumer Checkins
Autobind can be initiated by rhsmcertd when attempting to ‘heal’ the consumer. If autobind is disabled
for the consumer's owner, it will be affected in the following ways:

- Only affected if healing is enabled in rhsmcertd and on the consumer itself.
- Wouldn't result in any extra entitlements as the healing request will be blocked due to the org level setting.
- End result would be a failed healing request that results in no new entitlements granted to the consumer.

> **NOTE:**
>
> The reason why no entitlements were found would only be visible in the rhsm.log
>
> Without a client update, we can not present a more informative message.

#### Direct Autobind From Subscription Manager
Autobind can be invoked from the CLI or the GUI. If autobind is disabled
for the owner, it will be affected in the following ways:

**GUI**

- The autobind process will fail, presenting an error to the user stating that autobind has been disabled for the owner.

**CLI**

_subscription-manager register --auto-attach_

+ would result in a successful registration, but no entitlements due to the org level _disableAutobind_ setting.
+ client will report the standard “Unable to find available subscriptions for all your installed products.” message.
  - Without a client update, we can not present a more informative message.
+ The reason why no entitlements were found would only be visible in the rhsm.log

_subscription-manager attach --auto_

+ would result in no entitlements due to the org level setting.
+ The reason why no entitlements were found would only be visible in the rhsm.log

> **NOTE:**
>
> Without a client update, we can not present a more informative message.

#### Registering With Activation Keys
When registering with an activation key, auto attach can be invoked by setting the autoAttach property on the key(s).
If autobind is disabled for the target owner, it will be affected in the following ways:

+ ALL keys specified on registration will fail, even if one of them had autobind enabled.
+ If a failure occurred, the entire registration process is rolled back.
+ Appropriate message is displayed by the client.

#### Heal Entire Owner/Org
The _POST /owners/:owner_key/entitlements_ API call will attempt to heal all consumers in the targeted org.
If autobind is disabled for the target owner, it will be affected in the following ways:

+ If the target owner has autobind disabled, an error response with a meaningful message would be set in
  the job’s result data, and the job would fail.

#### Hypervisor Checkin
On hypervisor checkin, the host/guest mapping update will be skipped if autobind is disabled on the owner
leaving candlepin in the state of the 'last checkin' until autobind was again enabled.

+ Any potential migrations would occur the next time the virt-who checkin occurs.
+ Guests would heal themselves the next time rhsmcertd checks in.
+ Response will be a 400 - Bad Request in the case that autobind is disabled for the target owner.

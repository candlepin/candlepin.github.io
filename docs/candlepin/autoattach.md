---
title: Auto Attach
---
{% include toc.md %}

# Auto Attach
Auto Attach is designed to join the correct quantity of the correct pools with a
consumer in order to fully provide as many products as possible.

This document is intended to provide details on the Auto Attach algorithm.
The [first section](#diagrams) is a set of diagrams each intended to explain in greater
detail the Auto Attach algorithm. The [second section](#AlgorithmText)
provides a more intricate textual description of the process.

## Diagrams {#diagrams}

### Overview of the Auto Attach algorithm (Diagram 1) {#diagram1}
{% plantuml %}
title Auto-Attach Overview

start

if (System is Virtual Guest?) then (Yes)
  :Attach to virtual guest's hypervisor subscriptions that
  will provide subscriptions to cover the products required
  by the virtual guest;
else (No)
endif

:Filter out subscriptions that do not fit this system or have insufficient quantity;

:Filter out already compliant products;

:Sequentially select best subscription[note1] from those
available until all products are covered or all subscriptions
are exhausted;
note right: [note1] or group of subscriptions

stop
{% endplantuml %}


### How Auto Attach determines what to attach (Diagram 2) {#diagram2}

{% plantuml %}

title Auto-Attach Details
start

if (Are You a Guest Machine?) then (Yes)
  :Attach host to subscriptions which\nwill supply virt subscriptions\nneeded by guest;
note right: [1]
else (No)
endif

:Filter out subscriptions that do not fit this system;
note right:[2]

:Filter out compliant products if separate list supplied;

if (Is system V3 certificate capable?
[Only older systems will not be]) then (No)
  :Filter out subscriptions with\n>185 content sets;
else (Yes)
endif

:Filter subscriptions for additional attributes;
note right:[3]

:Filter out subscriptions with no remaining quantity;

:Filter out products from installed
list that are already compliant;

:Aggregate subscriptions that have a common stack id;

:Refine stacks for product specific coverage;
note right:[4]

while (Are all products covered or are the subscriptions exhausted?) is (No)
: Attach next best subscription;
note right: (See Select Best Pools Diagram below)
endwhile (Yes)
: End;
stop

{% endplantuml %}

#### Footnotes for Diagram 2
[\[1\]](#diagram2footnote1)
[\[2\]](#diagram2footnote2)
[\[3\]](#diagram2footnote3)
[\[4\]](#diagram2footnote4)
[\[5\]](#diagram2footnote5)



### Select Best Pools diagram (Diagram 3) {#diagram3}
{% plantuml %}

title Attach to best subscription or\n stack of subscriptions

(*) --> "Subscriptions remaining to check?" as more_data
note right: [start]

more_data --> [Yes] "is system a virtual guest?" as is_guest
more_data -left-> [No] "Return best" as return

return -up-> (*)
is_guest --> [Not Virtual guest] "Check number of products covered" as r
r -right[#green]-> [More] "Select as current best\nReturns to [start]" as update_best #green


r -down[#red]-> [Less] "Skip this subscription\nReturns to [start]" as do_not_update_best #red
r -[#blue]-> [Equal] "Check subscription priority" as p

p -right[#green]-> [Higher] update_best
p -left[#red]-> [Lower] do_not_update_best
p -[#blue]-> [Equal] "Check required quantity" as crq
crq -right[#green]-> [Lower] update_best
crq -down[#red]-> [Higher] do_not_update_best
crq -[#blue]-> [Equal] "is new not stacked and old stacked?" as new_stacked
new_stacked -right[#green]-> [Yes] update_best
new_stacked -down[#red]-> [No] do_not_update_best
is_guest -right-> [Virtual Guest] "Check number of host_required" as host_required
host_required -right[#green]-> [More] update_best
host_required -down[#red]-> [Less] do_not_update_best
host_required -[#blue]-> [Equal] "Check number of virt_only" as virt_only
virt_only -right[#green]-> [More] update_best
virt_only -down[#red]-> [Less] do_not_update_best
virt_only -[#blue]-> [Equal] r
{% endplantuml %}


### How SLA affects Auto Attach (Diagrams 4 & 5) {#diagram4_5}

The following diagrams show how SLA affected the auto attach algorithm up to candlepin version 2.4 and how that changed from 2.5 onwards.

{% plantuml %}

title Diagram 4: Auto-Attach Pool selection based on SLA (candlepin 2.4 / rules 5.26)

(*) --> "Is Pool SLA null or in the exempt list?" as is_pool_sla_null_or_exempt

is_pool_sla_null_or_exempt --> [Yes] "pool is selected for autoattach\nbut not prioritized for SLA" as selected_non_prioritized #yellow
is_pool_sla_null_or_exempt --> [No] "SLA override provided on attach request?" as is_sla_override_provided

is_sla_override_provided --> [Yes] "Pool SLA matches that SLA" as pool_matches_sla
is_sla_override_provided --> [No] "Consumer has SLA preference?" as consumer_has_sla_preference

pool_matches_sla --> [Yes] selected_non_prioritized
pool_matches_sla --> [No] "Pool is not selected during autoattach" as pool_is_not_selected #red

consumer_has_sla_preference --> [Yes] pool_matches_sla
consumer_has_sla_preference --> [No] "Owner has a default\nSLA preference set" as owner_has_default_sla

owner_has_default_sla --> [Yes] pool_matches_sla
owner_has_default_sla --> [No] selected_non_prioritized

{% endplantuml %}


{% plantuml %}

title Diagram 5: Auto-Attach Pool selection based on SLA (candlepin 2.5 / rules 5.27)

(*) --> "Is Pool SLA null or in the exempt list?" as is_pool_sla_null_or_exempt

is_pool_sla_null_or_exempt --> [Yes] "pool is selected for autoattach\nbut not prioritized for SLA" as selected_non_prioritized #yellow
is_pool_sla_null_or_exempt --> [No] "Consumer has at least one existing\nentitlement with an SLA set?" as consumer_has_existing_entitlement_with_sla_set

consumer_has_existing_entitlement_with_sla_set -left-> [Yes] "A Consumer entitlement SLA\nmatches the Pool SLA?" as consumer_entitlement_sla_matches_pool_sla
consumer_has_existing_entitlement_with_sla_set -down-> [No] "SLA override provided\non attach request?" as is_sla_override_provided

consumer_entitlement_sla_matches_pool_sla --> [Yes] is_sla_override_provided
consumer_entitlement_sla_matches_pool_sla -left-> [No] "Pool is not selected\nduring autoattach" as pool_is_not_selected #red

is_sla_override_provided --> [Yes] "Pool SLA matches that SLA" as pool_sla_matches_that_sla
is_sla_override_provided --> [No] "Consumer has SLA preference?" as consumer_has_sla_preference

pool_sla_matches_that_sla -left-> [Yes] "Pool selected during autoattach\nand prioritized +700" as pool_selected_and_prioritized #green
pool_sla_matches_that_sla --> [No] selected_non_prioritized

consumer_has_sla_preference -left-> [Yes] pool_sla_matches_that_sla
consumer_has_sla_preference --> [No] "Owner has a default SLA preference set" as owner_has_default_sla

owner_has_default_sla --> [Yes] pool_sla_matches_that_sla
owner_has_default_sla --> [No] selected_non_prioritized

{% endplantuml %}


## The Algorithm {#AlgorithmText}

Below is a more detailed and technical description of the Auto Attach process.
If you are looking for details on why Auto Attach chose a particular set of
pools, start with the [diagrams](#diagrams)

### Validate Pools
The rules.js is passed a context, which contains important data such as the
consumer, service level, pools available, products to cover, and a compliance
status at the time healing will take place

We can safely remove all pools from this list that:

* have SLAs that do not match any of the consumer's existing entitlement SLAs found in the compliance status. (unless either the pool's SLA is null or in the exempt list, or the consumer does not have existing entitlements, or the consumer has existing entitlements but none of them have an SLA set).
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
whether or not the pool SLA matches the consumer's SLA, or the pool is virt_only/requires_host,
and other factors (see note [\[5\]](#diagram2footnote5) for details), so those are preserved as long as possible.
Try removing one pool at a time, and check compliance with
everything else (that has not been removed) at max quantity.  If the stack is
compliant and covers all the same products, disregard the removed pool,
otherwise add it back.

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

### Select Pool Quantity
This is very similar to prune pools, except we know that every pool is
necessary, and we want the minimum quantity per pool.  loop over pools again,
adjusting quantity to consume, starting at the minimum increment, up to max
available, until the stack is compliant.  return a map of pool id to pool
quantity for candlepin to interpret.

### Accomodating Guests
When a guest attempts to Auto Attach, the host will first attempt to Auto Attach, with some significant changes:

1. The host will be handed the guests list of installed products, and attempt to Auto Attach with these
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


### Footnotes

#### Diagram 2 Footnotes

##### [1] {#diagram2footnote1}
The host to be auto-attached in a specific way such that the guest can use the resulting derived pools.  
This is done by accumulating pools to use based on the guest’s installed products.  
The possible pools for the host to attach will be determined as follows:  

1. Start with the set of all pools available for the current owner.  
1. Take only those that were provided with the request (if none, take all).  
1. Remove those pools for which the host has a current entitlement.  
1. Remove pools that already have a partial stack.  
1. Remove pools that only provide products for which there is a virt_only pool (available to the guest).  
1. Filter out pools using the regular preEntitlement rules (see [2]) for the host.  
1. If a pool has derived products then the available pools for the host will be filtered based on those and their match to the guest’s products.  
1. The host auto-attach will be executed based on the normal rules but over the set of pools determined above.  

[Back to Diagram 2](#diagram2)

##### [2] {#diagram2footnote2}
Pool filtering is done in the JavaScript rules based on parameters of the consumer and pool. Each is applied if and only if the parameter exists on the pool or the pool product.

virt_only: remove if not a guest consumer.  
physical_only: remove if a guest consumer.  
unmapped_guest_only: remove if not a guest or if guest has a known host.  
requires_host: remove if consumer is not a guest or if it does not have the specific host.  
requires_consumer: remove if not the specific consumer.  
requires_consumer_type: remove if not the specific consumer type.  
vcpu: remove if consumer vcpu count exceeds the product’s count [unless stackable].  
architecture: remove if the consumer’s arch is not in the product’s arch list.  
sockets: remove if consumer socket count exceeds the product’s count [unless stackable].  
cores: remove if consumer core count exceeds the product’s count [unless stackable].  
ram: remove if consumer ram count exceeds the product’s count [unless stackable].  
storage_band: remove if consumer band storage count exceeds the product’s count [unless stackable].  
instance_multiplier: remove if quantity requested does not divide evenly by the pools instance multiplier.  

[Back to Diagram 2](#diagram2)

##### [3] {#diagram2footnote3}
The following consumer to pool compatibilities are checked:
Is the consumer arch in the pool product arch list?  
Is the consumer guest status compatible with the pool virt_only/physical_only?  
Is any of the consumer's existing entitlement SLAs matching with the pool's SLA? (this check is performed only if the pool's SLA is non-null and not in the exempt list, and the consumer has existing entitlements and at least one of them has an SLA set).

[Back to Diagram 2](#diagram2)

##### [4] {#diagram2footnote4}
1. Check the coverage of the stack.
    * meaning do all product attributes summed up across all pools in the group completely cover those same attributes as required by the consumer)
1. If not covered: Remove all pools in the entitlement group which have at least one conflicting attribute (e.g. ARCH, attributes with a reason given).
1. Remove entitlement group from consideration if *still* the stack coverage is invalid.
1. If covered: Keep the entitlement group (for now).
1. Remove the entitlement group if there are no provided products by this group that are required by the consumer.
1. Find the stack containing the least pools/enforcing the least attributes that is still “covered” (pick combo of pools with least attributes by the average priority of each sub group).
1. Choose each stack_id in the consumer compliance that is listed in “partialStacks”, remove the overlap of products from the shared list of installed products.

[Back to Diagram 2](#diagram2)

##### [5] {#diagram2footnote5}
Priority score for a single pool. A stack of pools is scored by its average:  

The starting score is 100  
sla matches consumer sla +700 (see [diagram 5](#diagram4_5) for details)  
virt_only +100  
requires_host +150  
match to required sockets, cores, ram, or vcpu (+20 max for each based on closeness to consumer’s need)  
Share derived -10  

[Back to Diagram 2](#diagram2)

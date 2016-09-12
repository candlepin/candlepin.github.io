---
title: Virt Guest Limit Design
---
{% include toc.md %}

# Virt Guest Limit Design

## The Virt Guest Attribute
2013 RHEL Server subscription should have a guest_limit attribute with value "4"
This attribute is important because it allows us differentiate between 2013 subscriptions
with a virt guest limit, and only rhel server subscriptions.  Additionally,
this gives us a new attribute that can be modified for future pricing changes.

### Exceptions
RHEV and OST subscriptions should have a guest_limit attribute with value "-1"
which indicates unlimited virtual guests are allowed.

## Calculation of the Guest Limit Attribute
The guest_limit value is global, we will use the highest number (-1 being very high) and
apply it to every subscription that has a guest_limit value when we calculate compliance.
If there are more guests than supported, every subscription with guest_limit should become "insufficient."
There will be no changes to the number of virtual subpools created by datacenter subscriptions

## Implications for Existing Subscriptions
This requires new attributes on (hypervisor) subscriptions, but allows us to
futureproof.  Without the new attribute, It will become increasingly difficult
to support this in the future.  It gives the added benefit of the possibility
of a medium-density hypervisor, or a hypervisor subscription that doesn't
increase the limit.  This gives us the ability to create hypervisors with
different limits, so we won't have to worry about product ID logic and
installed product checks.

## Implementation

### Candlepin
When compliance starts, loop through all entitlements to find the maximum
guest_limit attribute.  We can probably preserve the current structure of
stackable attribute checking if we add a new hook for the starting value of the
"currentStackValue" stack tracker attribute, and no-op when we update the
attribute from a new pool.

Pre_entitlement should not check the virt max attribute, because like stackable subscriptions,
it depends heavily upon other subscriptions.  It may be worth rethinking pre_entitlement rules
in order to support subscriptions whose compliance relies upon other attached subscriptions,
as that case is becoming increasingly more common.

This attribute should be a "stackable attribute" in the code, even though it
doesn't actually stack.  That way a bad subscription will invalidate an entire
stack (just like Arch).

Autobind probably won't fully support this feature because it would need to
take into consideration that an entitlement or stack will be "healed" by adding
another, unrelated, subscription that doesn't necessarily provide any products.
This is acceptable because if there's no subscription already attached, the
consumer probably isn't actually using a hypervisor that supports more than 4
guests.

### virt-who
It looks like it's only immediately important to report active/inactive on the
kvm hypervisor.  It's probably a good idea to hold hypervisor-type in the
GuestID class, in addition to isActive.  We can check for the guest_limit
capability before sending the extra information to avoid breaking old
candlepins.  We will default to the current behavior when the capability is not
found.

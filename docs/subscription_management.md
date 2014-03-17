---
layout: default
title: Subscription Management
---
{% include toc.md %}

# Subscription Management 
Candlepin is designed such that the entitlement pools used to track entitlement
consumption can be backed by a separate subscription system. An implementation
of the SubscriptionServiceAdapter interface is the sole location where the
subscription data is accessed from. Subscriptions will follow the following
lifecycle with states that can be inferred primarily from their begin and end
dates. 

![](/images/subscription_states.png){:.center-block}

# State Definitions
The following states, are in the above diagram

Entered
: The subscription is valid, but has not yet been activated. 

Active
: The subscription is currently active

Termintated
: The subscription has been stoped becuase of operations or customer choices.

Expired
: The customer allowed the subcription to lapse

# Transitions and Their Effects
1. As time passes, the current day is greater than or equal to the begin date,
   the subscription becomes "Active"
1. Any back office activited could cause an update to the end date or the
   quantity. It is assumed that neither the ID nor the Product will change.
1. During Renewals (Wether done before the end date or after the end date) will
   result in a new end date. The ID will not change becuase of a renewal.
1. Termination is a result of some back office process. In this case, the end
   date is changed to reflect the date of the termination.
1. As time passes, a subscriptions end date may be in the past. It is no longer
   active.  No data changes occur here.
1. If an entered subscription is cancelled, the end ate is changed to the start
   date and never becomes active.

# New Entitlement Generation 
Based on the above states, when consumer asks for a new entitlement and the
pool is backed by subscription data the following steps are done

* Query all subscriptions for the given owner/product.
* Query all existing entitlement pools for that owner/product.
* Update all pools tied to those subscriptions.
  * If a subscription is being reduced, we take no action to remedy excess
    consumption. The pool information is updated, and the customer could now be
    out of compliance. Compliance processing will be responsible for taking
    appropriate actions. More on this below. 
* Create new pools for any new subscriptions.
* If a subscription has vanished and an entitlement pool exists for it, flag
  the pool as inactive, to be dealt with during compliance checking.

# Compliance Checking
None of this exists yet.
{:.alert-caution}

In a separate batch job we will intermittently run, we update *all*
subscription data, and scan the database looking for the following scenarios:

* An entitlement pool whose subscription was reduced and now has too many active entitlements.
* An entitlement pool whose subscription was deleted or terminated.
* An entitlement pool which has expired.

In each case, we need to determine what to do. 

# Current proposal
* Revoke invalid entitlements:
  * If subscription terminated/expired, revoke them all.
  * If subscription reduced, revoke the required number of entitlements
    starting with those most recently given out.
  * For each revoked entitlement:
    * Trigger a request for an entitlement for the exact same product.
    * Request will land in the javascript rules as usual to determine if the
      entitlement can be granted.
    * Modify rules engine to provide a list of all available entitlement pools
      to the rules.
    * Modify rules engine to provide a flag signaling that this is an automatic
      request for a re-entitlement.
    * Rules may optionally select which entitlement pool to use, or to refuse
      the entitlement if it's an automatic subscription.
    * Record entitlements lost, as well as successful re-entitlements so client
      tools or management applications can present this to the user.
    * Subscription could optionally carry an attribute pointing to an "old"
      subscription it is replacing, which the rules could use to determine
      which pool to use, should we wish to do this.

---
layout: default
title: Constraints
---
{% include toc.md %}

# Subscription Constraints
When reviewing the types of subscriptions that could exist, the thinking has
been that subscription types are modeled as "constraints" which business rules
may choose to enforce when consumers ask to create new entitlements. The types
of constraints which have been identified include

## Quantity Limited (physical & virtual)
Quantity based entitlements are simply limited by the number available.
Typically, it is a fixed number limiting what you can use.
But there can also be other criteria involved such as...

 * Quantity of Product = Number of Entitlements.
 * Product defines limits/criteria.
 * Product defines rules of consumption for Guests.
 * Guests are defined as "active" virtual guests. 

## Version Limited
 * Consumers with certain attributes can only consume products with a given version.

### Example
Locked at a specific version, upgrades are not included. Maybe be coupled with other limitations.

## Hardware Limited (i.e # of sockets, # of cores, etc)
 * Consumers with certain attributes (e.g. number of sockets) 

### Example
Sometimes you want to tie a product to particular hardware information. Typical server model is to limit a deployment to two (2) cpu sockets or cores.

## Functional Limited (i.e. Update, Management, Provisioning, etc)

### Example
This type of entitlement would unlock specific functionality of a given application, used for upselling purposes.

## Site License

### Example
You can use the application anywhere in your site.

## Floating Subscription

### Example
The floating license concept reminds me of the old FrameMaker licenses of the
old days. Where you get a license to use 10 copies simultaneously, anything
over that requires someone to close the application to free up a license.

## Value-Based or "Metered" (i.e. per unit of time, per hardware consumption, etc)

### Example
Metered is similar to the cell phone usage. Basically you pay for what you use.
Could be based on unit of time, cpu cycles, any other criteria accessible.

## Draw-Down (i.e. 100 hours or training classes to be consumed over some period of time or limited number of support calls)

### Example
Draw down is probably best used for things like training. Here is a set number
of hours or usage period. Once you have used it up, there is no more.

## Cloud Subcriptions
Similar to quantity based, but the consumers are potentially shorted lived.
This is similar to "Concurrent users" as a licensing model.

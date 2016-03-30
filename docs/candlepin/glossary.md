---
title: Glossary
---
# Candlepin Terms
It is helpful to understand the high level terms in the candlepin data model. A basic diagram of the model is:



Owner
: an organization who has purchased subscriptions to products.

Marketing Product
: A piece of software or service which can be used by the owner.

Subscription
: The right to consume a given Marketing Product.

Subscription Pool
: The right to consume a given Marketing Product. It is essentially a copy of Subscription with additional processing done by Candlepin. Candlepin chooses to operate with Subscription Pools instead of with Subscriptions directly.

Consumer
: An entity (person, system, etc) within the owner who may wish to make use of products.

Entitlement
: Consumption of a Subscription Pool by a Consumer.

You will also see the other terms used throughout the wiki

Entitlement Certificate
: By default, an x.509 certficate which represents you right to consume a subscription. This certificate can be used to access software.

Identity Certificate
: By default, an x.509 certificate which unique identifies a single consumer.

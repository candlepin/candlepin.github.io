---
layout: default
title: Glossary
---
# Candlepin Terms
It is helpful to understand the high level terms in the candlepin data model. A basic diagram of the model is:

![](/images/model.png){:.center-block}

In that diagram you will see the following terms

Owner
: an organization who has purchased subscriptions to products.

Subscription
: The right to consume a given product.

Product
: An item or service which can be subscribed to by the owner.

Consumer
: An entity (person, system, etc) within the owner who may wish to make use of products.

Entitlement
: The right to use a product

Entitlement Pool
: The collection of entitlements which are available to be consumed based on a subscription

You will also see the other terms used throughout the wiki

Entitlement Certificate
: By default, an x.509 certficate which represents you right to consume a subscription. This certificate can be used to access software.

Identity Certificate
: By default, an x.509 certificate which unique identifies a single consumer.

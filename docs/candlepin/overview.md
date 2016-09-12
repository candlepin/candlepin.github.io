---
title: Overview
---
{% include toc.md %}

# Business Problem
Software providers, whether they sell licenses or subscriptions, all have the
problem of tracking what products a customer has purchased, and which of those
the customer has consumed. For smaller customers, this can be a hosted solution
where the customer, or some code on the customers behalf, "phones home" in
order to consume a purchase. For larger customers, they may wish to manage
their products in a disconnected on-premises solution.

The Candlepin project is an open source software engine which has been designed
to solve this problem. It provides an API for client code to ask "What
subscriptions can I have" and then to actually assign a subscription to that
client. That assignment, or entitlement, therefore allows the consumer to make
use of the software or a feature of the software.

Candlepin has built in exention points for the concept of "Subscriptions",
"Products" and the business rules to actually do the assignment. In that way, a
specific vendor need only integrate to these extension points and then they can
take advantage of the core engine functionality.

# Deployment
In the simplest case Candlepin is deployed in an ISV's hosted environment, and
has a feed (or calls out to get) Order and Product Data. Then, remote clients
(Entitlement Managers) can call into Candlepin to consume the entitlements
which were created from the orders. The EMs provide client information, and
pull down identity and entitlement data.

![]({{ site.baseurl }}/images/simple.png){:.center-block}

In a more robust case, a hosted Candlepin can provide data to a remote
Candlepin installation. This allows larger customers to manage their
subscriptions in a secure fashion but within their own networks.

![]({{ site.baseurl }}/images/on-premise.png){:.center-block}

The design goal is to allow candlepin instances to federate this data out. So,
if a central group manages purchasing for a large company, they then should be
able to download the subscription data from the ISV and send some of it to
different departments who can then manage their own entitlements.

# Overview
Candlepin is a Java based engine which supports mapping the product
subscriptions which an owner has into a pool of entitlements which can be
consumed. Since much of this data can be unique per deployment, the engine
supports several extension points which can be replaced at deployment time. The
high level engine looks like this:

![]({{ site.baseurl }}/images/components.png){:.center-block}

## Extension Points
The Engine supports the following extension points:

* Subscription Data: A service call for the source of an owners subscriptions.
* Product Data: A service call for the products which subscriptions are made against.
* Entitlement Certificate Generation: A Service call to generate a flat file representation of an entitlement
* Identity Certificate Generation: A Service call to generate a consumers identity
* Event Publishing: A means of publishing out business events which occur in the system
* User Data: How users are authorized and authenticated to candlepin.
* Business Rules: Pluggable JavaScript rules which control
  * If a consumer can consume an entitlement to a subscribed product.
  * What is the "best" product for the consumer to be subscribed to.
* Batch Jobs: Clusterable batch jobs

# Certificates
In the base implementation, identity and entitlements are all represented by
x.509 certificates. The choice was made to use these formats so that standard
SSL client and servers could be used to (1) write Entitlement Management
clients and (2) provide secure access to software downloads. The generation of
entitlement and certificate data is one of the extension points, so it is
possible to replace those with custom implementations.

# Basic Client Lifecycle
Clients (called consumers) go through the following standard lifecycle:

1. Clients register with candlepin. They are given identity certificates which contain their UUID. This identity certificate can be used for future communication.
1. Clients can search for pools of subscriptions.
1. Clients consume susbcription(s). This is also called binding to a subscription or creating an entitlement. This results in entitlement certificates being provided to the client.
1. Clients can retrieve updated certificates to handle cases where data has changed server side.
1. Clients can unbind, or stop consuming certificates.
1. Clients can unregister, or delete themselves from the system.

# Terms
See the [Candlepin glossary](glossary.html).

# API
The engine exposes an API over REST. The API [description](api.html) provides details about what can be done.

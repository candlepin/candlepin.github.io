---
layout: default
title: Associating Hosts and Guests in Candlepin
---
{% include toc.md %}

# Associating Hosts and Guests in Candlepin

## Overview
For some entitlements, it is desirable to have access to host/guest
associations. For example, YYZCorp might have a product PoutineOS for Virtual
Servers, which, when entitled to a virtual host machine, allows that host to
have up to 4 guests using PoutineOS without consuming any regular entitlements.
Candlepin could simply ensure that only 4 systems are consuming PoutineOS
across the entire owner, but to be correct, we need to know that these guests
are actually running on the host that has the entitlement for PoutineOS for
Virtual Servers. Thus, Candlepin needs to know the host/guest associations.

## Assumptions
A virtual guest is able to view its uuid.

A virtual host is able to view all of the uuids of its guests.

A uuid is any reasonably unique identifier that is assigned to a virtual guest.
It doesn't matter which framework defines it (it could be from libvirt, or
vmware, etc), so long as both the host and guest system agree on the same
value.

Guests and Hosts will only be associated under the same owner.

## Client Side/Guest
Guest machines will be responsible for finding their virtual uuid, and sending
it to candlepin in a fact, virt.uuid. Subscription manager will take care of
this for us, using libvirt/virt-what.

## Client Side/Host
Hosts will be responsible for gathering a list of all of their client uuids.
They must include uuids for machines in all states (running, paused, stopped)
except for machines that have been destroyed or migrated.

Hosts will pass this info to candlepin in a fact, virt.guests, via a partial
fact update (or a full facts update, if other facts have changed). See the
server side section for more details.

There was talk of some host agent to take care of supplying this info. otherwise, rhsmcertd (or something new) will have to take care of updating this info.
{:.alert .alert-todo}

## Server Side

Especially if there is a client side agent, and if we wish to track guest state (running vs paused), we'll need to be able to modify the virt.guests fact without touching the rest of a consumers facts. Candlepin will expose new rest endpoints for working with a single fact:

POST/PUT candlepin/consumers/{uuid}/facts/{fact_key}
: create/modify an existing fact, the body of the request is simply a json
representation of the value for this key.

DELETE candlepin/consumers/{uuid}/facts/{fact_key}
: delete the given fact

GET candlepin/consumers/{uuid}/facts/{fact_key}
: read a single fact

Consumers already model a parent child relationship (see Consumer.getParent,
Consumer.getChildConsumers, and the backing fields). This code is unused,
however, but could be useful for ease of access to the hierarchy data. Instead
of using persisted fields, candlepin should use the host/guest facts to persist
parent/child relationships, and the ConsumerCurator should be responsible for
populating the consumer fields based on these facts when it loads a consumer.

Should we hook in javascript here for figuring out parent/child here, as
its based on facts?
{:.alert .alert-todo}

## virt.guests format
Consumer facts are key/value pairs, both strings. As we want to store a list in
virt.guests, we need to be careful about the format. virt.guests should be a
comma delimited list of uuids. If a uuid contains a comma, the comma must be
escaped with a \\. if a uuid contains a \\, it must be escaped with another \.

## Example 1
1. Consumer A registers to candlepin. On registration, it includes a fact
   virt.uuid = 123. Candlepin stores this fact as normal, and does nothing
   further.
1. Consumer A now attempts to bind to a pool. During the entilement logic
   (really, when the consumer data is loaded from the db), candlepin will check
   to see if there is another consumer with fact virt.guests containing
   Consumer A's virt.uuid. In this case, there is not, so Consumer A will have
   a null parent.
  1. Consumer A will bind as normal.

## Example 2
1. Consumer A registers to candlepin. On registration, it includes a fact
   virt.uuid = 123. Candlepin stores this fact as normal, and does nothing
   further.
1. Consumer B registers to candlepin. Consumer B is Consumer A's virt host, so
   it includes a fact virt.guests = yyz,123,emnop (it has two other guests).
   Candlepin stores this fact as normal, and does nothing further.
1. Consumer B binds to pool 'PoutineOS for virtual servers'.
1. Consumer A now attempts to bind to a pool. Candlepin sees that Consumer B's
   virt.guests fact contains Consumer A's uuid, and so it sets Consumer A's
   parent to Consumer B.
   1. Now during bind, Consumer A can take advantage of being a guest of B, and
      get a free entitlement to PoutineOS (or whatever entitlement logic we
      might have for virt products).

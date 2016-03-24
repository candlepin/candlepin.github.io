---
title: Virtualization 
---
This page may be out of date
{:.alert-bad}

{% include toc.md %}

# Virtualization Entitlements

## Assumptions:
* Some guests don't have information identifying their host machines
* There's no single consumer fact that identifies guest as such (distinct
  virtualization platforms can be identified by different facts)
* For Guest+Host model, if guest consumes an entitlement first, the free RHEL
  host entitlement is not going to be used.

In this light:

* RHSM client will have to be updated to query host for its host id, possibly
  to collect more facts about the consumer (might be virtualization-platform
  specific)
* a subset of rules will have to be run to identify if a given consumer is a
  guest or a host for rules that require this distinction

The logic below is going to be shared for all virtualization platforms:

## Guest Only
After rules identifying guest/host have been run, execute the guest-only rule
using the result. No changes for registration/consumption of an entitlement are
necessary.

## Physical Only
After rules identifying guest/host have been run, execute the host-only rule
using the result. No changes for registration/consumption of an entitlement are
necessary.

## Guest+Host
There are two possible workflows, depending on whether RHEL host is used or
not.

### With RHEL host:
A user installs RHEL host, and registers it. Upon consumption of a G+H:4 entitlement:

* Host part of G+H is consumed by the physical host;
* A pool consisting of 4 Guest entitlements with "host_id_restricted" set to
  physical host id is created.
* On guest registration, rhsm client may have to query the host for its id, and
  set host_id in facts
* Guests consume entitlements from this pool as usual, but an additional check
  of host id is performed by the rules engine.

### With only Guest entitlements of G+H being consumed (such as in the case with VMWare host):
* On guest registration, rhsm client may have to query the host for its id, and
  set host_id in facts

Upon consumption of the first G+H:4 entitlement by a Guest:

* A pool consisting of 4 Guest entitlements with "host_id_restricted" set to
  physical host id is created.
* An entitlement from the pool above is consumed by the guest.

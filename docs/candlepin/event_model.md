---
categories: design
title: Event Model Design
---
{% include toc.md %}

# Purpose
Candlepin has a general purpose eventing/messaging model, primarily used for
auditing (logging of changes to consumers), but ideally it can be used for
integration with other systems, email notification, irc bots, etc.

# Design

## HornetQ
We use [HornetQ](http://www.jboss.org/hornetq) messaging in Candlepin to take
care of delivering events to listeners. For "free", it gets us:
* guaranteed message delivery
* message persistence in case of server crash.

The HornetQ server runs inside Candlepin's servlet context; clients communicate with it via the InVM transport.

We serialize Events into HornetQ messages via JSON.

## Event
* Simple base class we use to represent an event.
* Carries data about:
  * Principal performing the action.
  * Date/time of the event.
  * Target type of the event: consumer, owner, entitlement
  * Type of the event: created, updated, deleted
  * ID of the owner of the object
  * ID of the object, combined will the event type, will allow queries for any specific object and event.
  * JSON blobs for old state of the object and new state of the object.
    * Can be loaded into a detached model object with Jackson.
* We will still need history timestamps on the actual entities themselves, as the event history table could grow large and need to be periodically archived.

## Event Factory
* helper class for Resources/Curators to create events with the proper type/target.
* serializes entities to JSON

## Event Sink
* Used by Resources/Curators to emit an event.

## Event Source
* registers listeners to receive events

## Listener
* Object adhering to simple interface to process an event.
* must implement void onEvent(Event e); called for each event

# Listeners
We have two listeners in candlepin, both of which are enabled by default:

DatabaseListener
: Logs events to the db in the cp_event table. The old and new entity fields are not logged.

LoggingListener
: Logs events to a file. Configurable via:

  * candlepin.audit.log_file - name of file to log to. defaults to /var/log/candlepin/audit.log
  * candlepin.audit.log_verbose - boolean option to log old and new entity fields. defaults to false (don't log the old/new fields)

# Events
Candlepin emits the following events:

1. Consumer Created
1. Consumer Deleted
1. Consumer Consumes From a Pool
1. Consumer Stops Consuming From a Pool
1. Owner is Created
1. Owner is Terminated
1. New Pool is Created for an Owner
1. Pool Quantity Changes

We plan to implement:

1. Consumer Facts Updated (not implemented in CP yet?)

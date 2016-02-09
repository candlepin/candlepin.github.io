---
categories: design
title: HornetQ Event Model
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

### HornetQ throttling and paging
HornetQ stores events in-memory or on hard disk. How much memory or how much hard disk it uses is based on configuration. See JavaDoc of the config options in ConfigProperties.java. The most important options are: 

* HORNETQ_ADDRESS_FULL_POLICY
* HORNETQ_MAX_QUEUE_SIZE
* HORNETQ_LARGE_MSG_SIZE

By correctly configuring these three options you can achieve one of the following limiting behaviors:

* Sizes of HornetQ in-memory queues (in megabytes) are upper bounded and threads that try to add more events into a queue are blocked. This limiting behavior is called throttling.
* Sizes of HornetQ in-memory queues (in megabytes) are upper bounded and any new Events are stored on disk instead of in-memory. This limiting behavior is called paging.

It is important to note that regardless of paging or throttling, events bigger then HORNETQ_LARGE_MSG_SIZE (in bytes) will always go to disk (thus may cause out of disk space). So sometimes it may be reasonable to set HORNETQ_LARGE_MSG_SIZE to a high number to ensure that no messages fall to the large category. 

For example the following config will put upper bound of 50MB to every queue in Hornet. It will block threads that try to add more events into queues. Thanks to high HORNETQ_LARGE_MSG_SIZE, it will also not page any messages < 1,000,000 bytes to disk.

```
 candlepin.audit.hornetq.address_full_policy=BLOCK
 candlepin.audit.hornetq.max_queue_size=50
 candlepin.audit.hornetq.large_msg_size=1000000
```

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

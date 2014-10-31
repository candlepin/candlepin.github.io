---
categories: Developers
title: Event Processing
---
{% include toc.md %}

# Event Processing

Gutterball connects to a to an AMQP (Qpid) message bus and listens for events from candlepin. Relative gutterball configuration values and their defaults can be found
[here](https://github.com/candlepin/candlepin/blob/master/gutterball/src/main/java/org/candlepin/gutterball/config/ConfigProperties.java).

When gutterball recieves an event from candlepin, the following occurs:

  * The event JSON from candlepin is converted into an Event object and is stored in the database, retaining the JSON for the old/new entity.

  * If there is a registered handler for the event (based on event target), the handler will process the event data and store the relevant data.

## Event Handling

Event handlers are responsible for processing event data that is recieved from candlepin. Each handler is defined around a candlepin Event target
and knows how to process the event based on its type (CREATED, UPDATED, DELETED).

### Event Targets and Their Types

An event target usually corresponds to 3 different types: CREATED, UPDATED, DELETED.

Gutterball's supported targets are listed below, along with the types of events that are handled.

#### COMPLIANCE

Candlepin will emit a compliance created event any time that a consumer's compliance status is recalculated on the server.
Events with this target are handled by the ComplianceHandler.

CREATED
: Handler retrieves the new entity data from the Event and converts it into a Compliance snapshot, and stores it in the DB.

UPDATED
: IGNORED: Compliance is always calculated by candlepin and is always considered a new object.

DELETED
: IGNORED: Compliance is always calculated by candlepin and is always considered a new object.


#### CONSUMER

Candlepin will emit an event with a CONSUMER target when a consumer is created, updated, or deleted. Events with this target are handled by the ConsumerHandler.

CREATED
: Creates a new ConsumerState object from the newEntity JSON (consumer representation) from the Event and stores it in the DB.

UPDATED
: IGNORED: There are no consumer updates that are of concern to gutterball at the moment.

DELETED
: Looks at the oldEntity (deleted consumer JSON) from the Event, looks up the ConsumerState by UUID, updates the 'deleted' timestamp on the state record, and stores it.
: This is how gutterball tracks if a consumer has been deleted or not.



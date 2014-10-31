---
categories: outdated
title: Old Design Overview
---
{% include toc.md %}

# Gutterball High Level Overview

Gutterball will be a java servlet optionally deployed along side Candlepin, as well as a component withing Satellite.

Gutterball will integrate with Candlepin by connecting to a message bus where Candlepin is emitting events, receiving those events, transforming them as necessary, and storing the data.

Gutterball will offer a REST API for asynchronously running a predefined set of reports on the data warehouse and returning the results as JSON.

UI for viewing reporting data will be implemented in Katello/Satellite.

## Data Storage

Data will be stored in a [mongdb database](mongodbsetup.html).

We will effectively be storing the JSON in events emitted from Candlepin. This
approach was chosen for simplicity in storing the event data, easier handling
of fields over time and across in scenarios where one Gutterball instance might
be data warehousing for a number of Candlepin servers of potentially different
versions.

The events can either be placed in MongoDB collections where each collection
represents one organization within Candlepin or in one large collection with an
index on organizations.

## Events
Many events in Candlepin are emitted when the event occurs.  This is not the case,
however, for subscriptions.  Subscriptions can expire or become active due to the date
ranges on the entitlement certificate.  Gutterball is interested in these events so to
make Candlepin emit them there are two proposed options.

1. Have Candlepin poll the database intermittently.  When the polling discovers
an entitlement that has passed a date threshold the event will be emitted by
the polling process but with the timestamp of the threshold event.  For
example, if a certificate expires at noon and we poll at 12:30, the event would
be emitted at 12:30 but be timestamped noon.  This option is the preferred
solution.
1. Have Candlepin write a Quartz trigger for the certificate thresholds when a
certificate is issued.  Then when the threshold date is reached, Quartz will
engage and fire the event.  This solution will only work for deployments that
use a Quartz database (generally the case for all production deployments).

Candlepin will also need to emit a new event describing compliance status.  The
compliance status event will include a full copy of the consumer and all the
consumer's entitlements but with the certificates and keys redacted.  The
compliance event will be sent after other events that require status recalculation:

  * create consumer (if the consumer has installed product IDs)
  * create entitlement
  * modify entitlement (make sure a SKU change triggers a modify entitlement)
  * delete entitlement
  * subscription becomes active
  * subscription expires
  * consumer modified (facts, guest IDs, installed product IDs, etc.)
  * rules change (it may not be worth pursuing, but technically a rules change
    could mean any system's status just changed and we would need to recalculate them all.)

In the case of a complex autobind only one compliance status event should be sent.

Candlepin will also store the latest compliance snapshot to reduce overhead.  Retaining
the latest compliance status could also allow us to stop calculating compliance on every
GET consumer API call.

The changes to the event framework will require Candlepin to keep track of events and only
emit them if the database transaction commits successfully.

By using native filtering functionality available in QPid, Gutterball will control
the events that it listens for.

Gutterball will store every compliance snapshot and the time it was calculated.
Reports will look for the most recent snapshot before report time.

## Reporting API

Gutterball will expose a [REST API](reportapi.html) for running a predefined set of reports, returning the results as JSON.

## Planned Reports

See the planned [supported reports](reports.html).

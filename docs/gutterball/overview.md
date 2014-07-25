---
categories: design
title: Gutterball Overview
---
{% include toc.md %}

# Gutterball High Level Overview

Gutterball will be a java servlet optionally deployed along side Candlepin, as well as a component withing Satellite.

Gutterball will integrate with Candlepin by connecting to a message bus where Candlepin is emitting events, receiving those events, transforming them as necessary, and storing the data.

Gutterball will offer a REST API for asynchronously running a predefined set of reports on the data warehouse and returning the results as JSON.

UI for viewing reporting data will be implemented in Katello/Satellite.


## Data Storage

Data will be stored in a [mongdb database](mongodbsetup.html).

We will effectively be storing the JSON in events emitted from Candlepin. This approach was chosen for simplicity in storing the event data, easier handling of fields over time and across in scenarios where one Gutterball instance might be data warehousing for a number of Candlepin servers of potentially different versions.

## Reporting API

Gutterball will expose a [REST API](reportapi.html) for running a predefined set of reports, returning the results as JSON.

## Planned Reports

See the planned [supported reports](reports.html).

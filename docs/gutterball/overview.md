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

Data will be stored primarily as JSON in a PostgreSQL database using the new binary json storage in 9.3.

We will effectively be storing the JSON in events emitted from Candlepin. This approach was chosen for simplicity in storing the event data, easier handling of fields over time and across in scenarios where one Gutterball instance might be data warehousing for a number of Candlepin servers of potentially different versions.

### PostgreSQL 9.3 Packaging Concerns

PostgreSQL 9.3 is not yet packaged for RHEL 6/7. There is a postgresql92 software collection which may give us something to work off.

Our proposal:

 * Build and maintain a 9.3 RPM in brew until such a time as one is mainainted for us.
   * Ideally we hope to build this in non-SCL form, in which case upgrading Satellite installations should be nearly trivial, typically just running a postgresql upgrade db command.
 * Only one PostgreSQL database in Satellite, all components will use the new version upgraded.
   * Our team will be responsible for ensuring upgrading existing Satellite's is smooth.
   * We intend to use binary JSON storage, other Satellite components are not required to, PostgreSQL should function as before for them.
   * We expect the change to have minimal impact on other components.

## Reporting API

Gutterball will expose a [REST API](reportapi.html) for running a predefined set of reports, returning the results as JSON.

## Planned Reports

See the planned [supported reports](reports.html).

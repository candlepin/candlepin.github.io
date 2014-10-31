---
title: Gutterball
---
{% include toc.md %}

# Gutterball
Gutterball is a reporting engine for Candlepin allowing users to report on system and subscription usage and aggregate that information over time.

## Overview

Gutterball is a java servlet optionally deployed along side Candlepin, as well as a component within Satellite. It integrates with Candlepin via a message bus.
Candlepin emits events to the bus and Gutterball will process them and store the relevant data.

Gutterball offers a REST API for asynchronously running a predefined set of reports on the data warehouse and returning the results as JSON.

UI for viewing reporting data will be implemented in Katello/Satellite.

### Data Collection/Event Processing

Gutterball integrates with Candlepin by making use of Candlepin's event message bus. Gutterball will process any events candlepin puts on the bus by transforming the event data and storing it in a database using hibernate.

[ [Read More](gutterball/events.html) ]

### Reporting API

Gutterball provides a REST API that allows consumers to run pre-canned reports against Gutterball's data store and is protected by OAuth. Each report provides various parameters that allow the caller to customize report results. Report results are returned as JSON.

[ [Read More](gutterball/reportapi.html) ]

{% project_index %}

---
categories: outdated
title: Compliance Calculation and Storage
---
{% include toc.md %}

# Compliance Calculation and Storage

NOT APPLICABLE ANYMORE - Compliance is reported over an Event Message Bus.


#### OLD IDEAS

Compliance is calculated by running consumer and entitlement JSON through Javascript rules from Candlepin.

Javascript rules can change over time, what should happen to saved compliance snapshots?

Should we save compliance snapshots at all or just calculate compliance as a report is running?

How does Gutterball receive/notice/detect when new Javascript rules are imported in Candlepin? (probably an event)

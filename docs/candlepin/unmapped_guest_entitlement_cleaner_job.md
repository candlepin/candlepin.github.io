---
title: Unmapped Guest Entitlement Cleaner Job
---
{% include toc.md %}

# Unmapped Guest Entitlement Cleaner Job

## Overview
The reoccurring unmapped guest entitlement cleaner job removes invalid entitlements that have the pool attribute "unmapped_guests_only". By default this job runs at 3:00 am and every 12 hours afterwards.

**Job key:** UnmappedGuestEntitlementCleanerJob

## Criteria for removal
- The Pool must have the "unmapped_guests_only" pool attribute.
- The entitlement has a start date after the current date and time OR an end date before the current date and time.

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description
| --- | --- | --- | --- |
| candlepin.async.jobs.UnmappedGuestEntitlementCleanerJob.schedule | 0 0 3/12 * * ? | Defines when to run the job (Cron job format)
---
title: Active Entitlement Job
---
{% include toc.md %}

# Active Entitlement Job

## Overview
The reoccurring active entitlement job recalculates compliance status for consumers with active entitlements. By default, this job runs every hour when active.

**Job key:** ActiveEntitlementJob

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description |
| --- | --- | --- |
| candlepin.async.jobs.ActiveEntitlementJob.schedule | 0 0 0/1 * * ? | Defines when to run the job (Cron job format)
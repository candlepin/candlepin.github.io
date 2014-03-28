---
layout: default
categories: developers
title: Pinsetter
---
{% include toc.md %}

# Pinsetter
Prevent some jobs from running concurrently. For example, if I call refresh pools on a given owner repeatedly I want at most 2 jobs scheduled.

* Types of jobs
  * concurrent
  * serial
* [JobListener](http://quartz-scheduler.org/api/2.1.7/org/quartz/JobListener.html)
* [SchedulerListener](http://quartz-scheduler.org/api/2.1.7/org/quartz/SchedulerListener.html)

## Current list of job classes

|Jobname | Schedule | Description |
-|-
| TransactionalPinsetterJob | N/A | wrapper of jobs with a UnitOfWork |
| RefreshPoolsForProductJob | async | refreshes the pools  |
| ExpiredPoolsJob | cron 0 0 0/4 * * ? | deletes expired pools |
| ImportRecordJob | cron 0 0 12 * * ? | truncates the import record table |
| RefreshPoolsJob | async | refresh the pools for the given owner |
| RegenEnvEntitlementCertsJob | async | regenerates the entitlements for the environment |
| MigrateOwnerJob | async | migrates the given owner to a new shard (uses API of another candlepin) |
| RegenProductEntitlementCertsJob | async | regenerate entitlements for pools that provide the given product |
| EntitlerJob | async | bind by pool, product, heal entire org |
| CancelJobJob | cron 0/5 * * * * ? | deletes the specified job from the scheduler |
{:.table-striped .table-bordered}

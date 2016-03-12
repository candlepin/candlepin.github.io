---
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

| Jobname | Cron/Async | Description |
---|---|---
| KingpinJob | N/A | A supertype between actual jobs and the Quartz Job. Gives us more freedom to define behavior. Every candlepin job must extend KingpinJob. |
| UniqueByEntityJob (previously UniqueByOwnerJob) | N/A | A supertype between actual jobs and KingpinJob. Can by extended by jobs that should not be run concurrently per entity (currently owners or consumers). A job will wait for the running job to finish before beginning execution. Any new schedule requests may be ignored if there is a similar job currently scheduled on the same target, but has not begun execution. Hence only jobs for which successive requests are no-ops should  extend UniqueByEntityJob. |
| ActiveEntitlementJob | 0 0 0/1 * * ? | Recalculates compliance for consumers when entitlements become active. |
| CancelJobJob | 0/5 * * * * ? | Deletes the specified job from the scheduler. |
| CertificateRevocationListTask | 0 0 12 * * ? | Synchronizes the CRL with the DB. |
| ConsumerComplianceJob | async | Evaluates the compliance status of a consumer, and updates the consumer if requested. |
| EntitleByProductsJob | async | Bind by pool, product for an entitle date. |
| EntitlerJob | async | Bind by pool, product, heal entire org. |
| ExpiredPoolsJob | 0 0 0/4 * * ? | Looks for any pools past their expiration date. If found we clean up the subscription, pool, and it's entitlements. This is primarily done on a scheduled basis to make sure we re-source derived pools if the stack has other still valid entitlements. |
| ExportCleaner | 0 0 12 * * ? | Examines the directory where the exporter compiles its information and resultant zip file. Data that is more that a day old will be expunged. |
| HealEntireOrgJob | async | Heals an entire org. Extends UniqueByEntityJob. |
| HypervisorUpdateJob | async | Refreshes the entitlement pools for specific org. |
| ImportRecordJob | 0 0 12 * * ? | Deletes all but N oldest records from the import record table. |
| JobCleaner | 0 0 12 * * ? | Removes finished jobs older than yesterday, and failed jobs from 4 days ago. |
| PopulateHostedDBTask | async | Worker implementation for populating Hosted's DB. |
| RefreshPoolsForProductJob | async | Refreshes the pools for the given owner, product. |
| RefreshPoolsJob | async | Refreshes the pools for the given owner. Extends UniqueByEntityJob. |
| RegenEnvEntitlementCertsJob | async | Regenerates entitlements within an environment which are affected by the promotion/demotion of the given content sets. |
| RegenProductEntitlementCertsJob | async | Regenerate entitlements for pools that provide the given product |
| StatisticHistoryTask | 0 0 1 * * ? | Calculates the statistics for an owner. |
| SweepBarJob | 0 0/5 * * * ? | Marks non-finished/failed/canceled job status ( orphaned jobs ) that do not correspond to a quartz jobs as "canceled". |
| UndoImportsJob | async | Removing pools created during manifest import. Extends UniqueByEntityJob. |
| UnmappedGuestEntitlementCleanerJob | 0 0 3/12 * * ? | Removes 24 hour unmapped guest entitlements after the entitlement has expired. Entitlements normally last until a pool expires. |
| UnpauseJob | 0/5 * * * * ? | Prompts each paused job to check if it is safe to continue executing. |
{:.table-striped .table-bordered}

---
title: Inactive Consumer Cleanup Job
---
{% include toc.md %}

# Inactive Consumer Cleanup Job

## Overview

The purpose of the inactive consumer cleanup job is to delete inactive consumers that fit the inactive criteria.  By default this job is not automatically scheduled by the system and so it must either be manually scheduled using the `/jobs/schedule/{job_key}` endpoint or a periodic schedule must be defined using the schedule property in the candlepin.conf file. The inactive consumer cleanup job first determines all the consumers that are inactive and then deletes the inactive consumers in batches. Before a batch of consumers are deleted, entries are made into the deleted consumers table for auditing purposes and all of the consumer's ID and SCA certificates are deleted and the corresponding serials for those certificates are revoked. Once a batch is completed, the number of inactive consumers that were deleted will be displayed in the candlepin logs.

**Job key:** InactiveConsumerCleanerJob

## Inactive Consumer Criteria

Consumers are considered inactive if they meet all of the following criteria.

(Consumers who have not checked in in the last 397 days **OR** (whose lastcheckin date is NULL **AND** the updated date is more than 30 days in the past)) <br>
**AND** <br>
Consumers that do not have any entitlements attached <br>
**AND** <br>
Consumers whose type is non-manifest.

## Configurable Properties

Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description |
| --- | --- | --- |
| candlepin.async.jobs.InactiveConsumerCleanerJob.schedule |  | Defines when to run the job (Cron job format)  |
| candlepin.async.jobs.InactiveConsumerCleanerJob.last_checked_in_retention_in_days | 397 | Number of days in the past where a consumer's last checked in date is considered inactive |
| candlepin.async.jobs.InactiveConsumerCleanerJob.last_updated_retention_in_days | 30 | Number of days in the past where a consumer's update date is considered inactive |
| candlepin.async.jobs.InactiveConsumerCleanerJob.batch_size | 1000 | The number of inactive consumers deleted in a single batch |
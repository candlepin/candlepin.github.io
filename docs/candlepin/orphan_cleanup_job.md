---
title: Orphan Cleanup Job
---
{% include toc.md %}

# Orphan Cleanup Job

## Overview
The reoccurring orphan cleanup job searches for orphaned product and content entities and removes them. By default this job runs every Sunday at 3:00 am.

**Job key:** OrphanCleanupJob

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description
| --- | --- | --- | --- |
| candlepin.async.jobs.OrphanCleanupJob.schedule | 0 0 3 ? * 1 | Defines when to run the job (Cron job format)
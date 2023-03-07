---
title: Job Cleaner Job
---
{% include toc.md %}

# Job Cleaner Job

## Overview
The reoccurring job cleaner job periodically removes terminal, non terminal, and or running jobs based on provided configurations. By default this job runs everyday at 12:00 pm.

**Job key:** JobCleaner

## Definitions
- Terminal job: A job in a state that will no longer change. Examples: Finished, failed, canceled, or aborted.
- Non terminal job: A job in a state that can change. Examples: Scheduled, waiting, running, or queued. 

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description
| --- | --- | --- |
| candlepin.async.jobs.CertificateCleanupJob.schedule | 0 0 12 * * ? | Defines when to run the job (Cron job format)
| candlepin.async.jobs.ImportRecordCleanerJob.JobCleaner.max_terminal_job_age | 10080 | The number of minutes in the past for terminal job retention
| candlepin.async.jobs.ImportRecordCleanerJob.JobCleaner.max_nonterminal_job_age | 4320 | The number of minutes in the past for non terminal job retention
| candlepin.async.jobs.ImportRecordCleanerJob.JobCleaner.max_running_job_age | 2880 | The number of minutes in the past for currently running job retention

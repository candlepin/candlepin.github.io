---
title: Import Record Cleaner Job
---
{% include toc.md %}

# Import Record Cleaner Job

## Overview
The reoccurring import record cleaner job periodically deletes all but a set amount of most recent import records from the cp_import_record database table. By default this job runs every day at 12:00 pm.

**Job key:** ImportRecordCleanerJob

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description |
| --- | --- | --- |
| candlepin.async.jobs.CertificateCleanupJob.schedule | 0 0 12 * * ? | Defines when to run the job (Cron job format)
| candlepin.async.jobs.ImportRecordCleanerJob.num_of_records_to_keep | 10 | Defines the amount of most recent imoport records to keep
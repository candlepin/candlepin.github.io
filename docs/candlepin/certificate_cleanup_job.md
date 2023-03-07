---
title: Certificate Cleanup Job
---
{% include toc.md %}

# Certificate Cleanup Job

## Overview
The reoccurring certificate cleanup job periodically deletes all expired identity and content certificates as well as all revoked and expired certificate serials. By default this job everyday at 12:00 pm.

**Job key:** CertificateCleanupJob

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description |
| --- | --- | --- |
| candlepin.async.jobs.CertificateCleanupJob.schedule | 0 0 12 * * ? | Defines when to run the job (Cron job format)

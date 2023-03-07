---
title: Manifest Cleaner Job
---
{% include toc.md %}

# Manifest Cleaner Job

## Overview
The reoccurring job cleaner job periodically removes all artifacts that may result from importing/exporting manifest files. By default this job runs every day at 12:00 pm.

**Job key:** ManifestCleanerJob

## Responsibilities

1. Examine the scratch directory where the importer/exporter writes temp files and deletes any that are older than a configured age (default 24 hours).

2. Deletes expired manifest files that live on the Manifest File Service (default 24 hours).

3. Deletes manifest file records that exist without a file in the service. This case should only happen if the Manifest File Service is remote, has already deleted the file, and deleting of the manifest file record has failed for some reason.

## Configurable Properties
Configurations that can be defined in the candlepin.conf file.

| Property Key | Default value | Description
| --- | --- | --- |
| candlepin.async.jobs.ManifestCleanerJob.schedule | 0 0 12 * * ? | Defines when to run the job (Cron job format)
| candlepin.async.jobs.ManifestCleanerJob.ManifestCleanerJob.max_age_in_minutes | 1440 | The number of minutes in the past used to define retention

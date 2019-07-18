---
title: Migrating to the Artemis Job System
---
{% include toc.md %}

As part of the improvements for job queueing, filtering and general performance, Candlepin is moving
away from a pure Quartz solution for job execution and is, instead, using a solution involving the
Artemis messaging system.

## Migration

Migrating from a Candlepin version using the "old" Quartz-based jobs to the new job system is no
different than a typical upgrade, however there are a few caveats of which the maintainers should
be aware:

1. The Candlepin migration/upgrade makes no attempt to preserve existing jobs that were running or
   in the queue when the upgrade process begins, and any existing job entries within Quartz may be
   removed as part of the upgrade.
1. Some APIs and output has changed slightly with the new system. Specifically, some job details
   are slightly different when fetching the status of a job, and there are additional states a job
   may be in.
1. Some configuration options have changed to be more clear and standardized with the other job
   configurations


This leaves the responsibility of timing, conversion and compatibility to Satellite's upgrade process
or the manual upgrade process followed for non-standard deployments (i.e. hosted). However, this sounds
worse than it acutally is: At the time of writing, both Satellite and hosted currently wait for manually
executed jobs to complete before performing an upgrade, most job configurations have only changed
location, not value, and the API changes have been minimized or duplicated to avoid compatibility issues
where possible.



## API Changes

While many APIs will remain indistinguishable in the new job system, some queries and features may not
be possible or are achieved through different means. Below is a list of known and expected changes, along
with the workaround if necessary.

- Several new job states have been added. The states which correspond to equivalent states in the old job
  system have retained the previous names.
- It is no longer necessary to provide the ```result_data``` query parameter to include the result when
  fetching job status

TODO: add more changes as necessary



## Configuration changes

In the Artemis-based job system, all job configuration has been standardized such that all job configuration
falls under the ```candlepin.async.``` path, with native job-specific config all falling under the
```candlepin.async.job.{job_key}.``` path. Note that non-native jobs may deviate from this schema.

Additionally, there are new configurations available for controlling whether or not jobs may or may not run
on a given node.

#### New Global Configurations

- **candlepin.async.threads**<br/>
  Controls the number of threads that will be created to process jobs. Must be a positive integer. Defaults to 10.
- **candlepin.async.whitelist**<br/>
  A comma-delimited list of job keys, representing the jobs that are allowed to be executed on any nodes using this configuration. Defaults to empty.
- **candlepin.async.blacklist**<br/>
  A comma-delimited list of job keys, representing jobs that are disabled on any nodes using this configuration. Defaults to empty.
- **candlepin.async.jobs.{job_key}.enabled**<br/>
  Enables or disables the job defined by {job_key}. If set to false, overrides any entries on the whitelist. Defaults to true.
- **candlepin.async.jobs.{job_key}.schedule**<br/>
  Sets a schedule to automatically execute the job defined by {job_key}, using a cron-like syntax. The job will be executed with zero parameters and without any validation. Care should be used when setting job schedules. Only one schedule may be defined for a job on a given node. Default value varies per native-job, defaults to empty for non-native jobs.

#### Converted and Dropped Job Configuration

- **pinsetter.tasks**<br/>
  Removed; automatically built based on job whitelisting and blacklisting
- **pinsetter.default_tasks**<br/>
  Removed; redundant
- **candlepin.pinsetter.enable**<br/>
  Moved to candlepin.async.enabled
- **pinsetter.waiting.timeout.seconds**<br/>
  Removed; currently unsupported.
- **pinsetter.retries.max**<br/>
  Removed; currently unsupported globally, can be set per-job in code
- **pinsetter.org.candlepin.pinsetter.tasks.ManifestCleanerJob.max_age_in_minutes**<br/>
  Moved to candlepin.async.jobs.ManifestCleanerJob.max_age_in_minutes
- **pinsetter.org.candlepin.pinsetter.tasks.EntitlerJob.throttle**<br/>
  Moved to candlepin.async.jobs.EntitlerJob.throttle; currently unsupported



## Controlling Job Execution

As part of the changes in the new job system, improvements have been made to controlling which jobs are
enabled on a given node. The system now supports whitelisting and blacklisting at a global level, as well
as enabling or disabling specific jobs at an individual level.

#### Blacklisting

The job blacklist is configured using the ```candlepin.async.blacklist``` option in candlepin.conf, and
consists of a comma-delimited list of job keys representing the jobs to disable on the node. Blacklisted
jobs may still be executed if a job is explicitly enabled.

Example:
```candlepin.async.blacklist=EntitlerJob,ManifestCleanerJob```

#### Whitelisting

Similar to the blacklist, the whitelist is configured usign the ```candlepin.async.whitelist``` option in
candlepin.conf, and consists of a comma-delimited list of job keys representing the jobs to allow on the node,
implicitly disabling all jobs *not* present in the list. A job on the whitelist may still be disabled if it
is on the blacklist or is explicitly disabled.

Example:
```candlepin.async.whitelist=RefresherJob,EntitlerJob```

#### Per-Job Configuration

Specified using the per-job configuration syntax, ```candlepin.async.jobs.{job_key}.enabled```, this option
enables or disables a job, regardless of the current whitelist or blacklist. Generally this should be reserved
for critical jobs that should always be enabled, or temporarily disabling jobs without needing to redefined
the entire white and blacklists.

Example:
```candlepin.async.jobs.{job_key}.enabled=true```

#### Configuration Priority

With three ways to enable or disable jobs, it's important to understand the order in which the options are
processed to ensure the system is working as intended. With all of the configurations, explicit values have
priority over implicit ones, which puts the per-job configuration at the top and the whitelist at the bottom.
The algorithm for determining whether or not a given job is enabled is as follows:

1. If the job-specific configuration option is specified, that value is used in all situations.
1. If no job-specific configuration option is provided, the blacklist is checked. If the job appears on the
   blacklist, it is disabled
1. If no job-specific configuration option is provided and the job does not appear on the blacklist, the
   whitelist is checked. If no whitelist is provided, or the job appears on the whitelist, it is enabled. If
   the whitelist is specified and the job is not present, it is disabled.
1. If all of the above checks fail or are otherwise inconclusive, the job is assumed to be enabled.


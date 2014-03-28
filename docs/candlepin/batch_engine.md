---
layout: default
categories: developers
title: Batch Engine
---
{% include toc.md %}

# Batch Engine
Candlepin will need the ability to schedule long running jobs to sync
subscription and product data. The engine itself is generic enough to use for
any scheduled job. 

## Adding a new task
Adding a new task to Pinsetter is quite simple, so simple it can be done in 3 easy steps.

 1. Create a class that implements the Quartz `Job` interface
 1. Add your fully qualified class name to the `tasks` configuration entry in `/etc/candlepin/candlepin.conf`
 1. Define a `public static String DEFAULT_SCHEDULE` or add a schedule entry to the same config

That's it. Pinsetter will now execute that job on the defined schedule.

## Sample Job
Here is a very simple job that prints when it was run.

```java
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Date;

/**
 * SimpleTask
 */
public class SimpleTask implements Job {
    
    /** must be in CRON format */
    public static final String DEFAULT_SCHEDULE = "0 * * * * ?";

    @Override
    public void execute(final JobExecutionContext ctx)
        throws JobExecutionException {
        System.out.println("simple task ran: " + new Date().toString());
    }
}
```

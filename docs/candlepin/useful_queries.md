---
title: Useful Queries
---
{% include toc.md %}

# Useful Queries

## How to force trigger a cron quartz job for debugging:

```postgresql
-- postgresql
update QRTZ_TRIGGERS set next_fire_time = (select extract( epoch from now() + interval '1 minute') * 1000) where job_name like  'ExpiredPoolsJob%';
```
```mysql
-- mysql
update QRTZ_TRIGGERS set next_fire_time = (select unix_timestamp(date_add(now(), interval 1 minute)) * 1000) where job_name like  'ExpiredPoolsJob%';
```

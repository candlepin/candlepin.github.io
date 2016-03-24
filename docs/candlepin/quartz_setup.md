---
title: Quartz Configuration
---
{% include toc.md %}

# Quartz Setup
In order to setup pinsetter for
[clustering](http://www.quartz-scheduler.org/documentation/quartz-2.x/configuration/ConfigJDBCJobStoreClustering),
you need to configure [quartz](http://www.quartz-scheduler.org/) to use a
relational database
([JdbcStore](http://www.quartz-scheduler.org/documentation/quartz-2.x/configuration/ConfigJobStoreTX))
instead of the default memory storage,
([RamJobStore](http://quartz-scheduler.org/documentation/quartz-2.2.x/configuration/ConfigRAMJobStore).

If you used `cpsetup` as described in the [Getting
Started](getting_started.html) guide you already have the Quartz schema
installed in your PostgreSQL database.

Not using PostgreSQL?  No problem.  Simply install the correct Quartz schema
located in `/usr/share/candlepin/schema/quartz` of the rpm install or
`code/schema/quartz` in your git checkout.

## Load Schema
Candlepin supplies a subset of the [Quartz
schema](http://svn.terracotta.org/fisheye/browse/Quartz/tags/quartz-1.7.3/docs/dbTables).
The files are named tables_DATABASENAME.sql where DATABASENAME is the database
you want to use to store Quartz information.

* `code/schema/quartz/tables_h2.sql`
* `code/schema/quartz/tables_hsqldb.sql`
* `code/schema/quartz/tables_mysql.sql`
* `code/schema/quartz/tables_oracle.sql`
* `code/schema/quartz/tables_postgres.sql`

Load the schema using the mechanism for your database.

## Configure Candlepin & Quartz
Once you have the Quartz schema deployed, you need to configure Quartz in
Candlepin to use those tables instead of the default RamJobStore.

I will cover each of the configuration items, if they can be changed, if they
are required to change, and if they are to be left alone.

### Configuration Properties
Also see the [Quartz documentation](http://quartz-scheduler.org/documentation/quartz-2.x/configuration/)

| Property | Required | Needs Changing? | Description |
-|-
| org.quartz.scheduler.instanceName | Y | N  | name for the Quartz instance, must use same name for every instance in the cluster |
org.quartz.scheduler.instanceId | Y | N | how the id is generated |
org.quartz.jobStore.class | Y | N | for database use org.quartz.impl.jdbcjobstore.JobStoreTX| 
org.quartz.jobStore.driverDelegateClass | Y | Y | see database mapping table below| 
org.quartz.jobStore.useProperties |Y | N | instructs JDBCJobStore to allow complex objects in JobDataMap| 
org.quartz.jobStore.dataSource | Y | Y | name you want to give datastore, needs to match what you use for datasource config later on| 
org.quartz.jobStore.tablePrefix | N | N | needs to match table ddl in quartz sql files (default QRTZ\_)|
org.quartz.jobStore.isClustered | Y | N | tells Quartz it is clustered| 
org.quartz.jobStore.clusterCheckinInterval | Y| N | how often in ms the cluster checks in|
org.quartz.dataSource.NAME.driver |Y | Y |Specify JDBC driver|
org.quartz.dataSource.NAME.URL| Y | Y | JDBC url for your driver| 
org.quartz.dataSource.NAME.user| Y | Y | database username| 
org.quartz.dataSource.NAME.password | Y| Y | password for database username| 
org.quartz.dataSource.NAME.maxConnections |N | N | number of connections in pool| 
{:.table-striped .table-bordered}

NAME in the table above must match the value in org.quartz.jobStore.dataSource
{:.alert-caution}

|database | driverDelegateClass | schema file |
-|-
| PostgreSQL | org.quartz.impl.jdbcjobstore.PostgreSQLDelegate | tables_postgres.sql | 
| Oracle | org.quartz.impl.jdbcjobstore.oracle.OracleDelegate | tables_oracle.sql| 
| MySQL | org.quartz.impl.jdbcjobstore.StdJDBCDelegate | tables_mysql.sql | 
| HSQLDB | org.quartz.impl.jdbcjobstore.HSQLDBDelegate | tables_hsqldb.sql | 
| H2 | org.quartz.impl.jdbcjobstore.StdJDBCDelegate | tables_h2.sql | 
{:.table-striped .table-bordered}

## Sample PostgreSQL config
These values should be placed in your Candlepin config file `/etc/candlepin/candlepin.conf`.
Candlepin will take care of configuring Quartz using these values.

```properties
#============================================================================
# Configure Main Scheduler Properties
#============================================================================
org.quartz.scheduler.instanceName = MyClusteredScheduler
org.quartz.scheduler.instanceId = AUTO
#============================================================================
# Configure JobStore
#============================================================================
org.quartz.jobStore.class = org.quartz.impl.jdbcjobstore.JobStoreTX
org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate
org.quartz.jobStore.useProperties = false
org.quartz.jobStore.dataSource = cpqrtz
org.quartz.jobStore.tablePrefix = QRTZ_

org.quartz.jobStore.isClustered = true
org.quartz.jobStore.clusterCheckinInterval = 20000
#============================================================================
# Configure Datasources
#============================================================================

#  this must match the value of org.quartz.jobStore.dataSource
#                     vvvvvv
org.quartz.dataSource.cpqrtz.driver = org.postgresql.Driver
org.quartz.dataSource.cpqrtz.URL = jdbc:postgresql:candlepin
org.quartz.dataSource.cpqrtz.user = candlepin
org.quartz.dataSource.cpqrtz.password = candlepin
org.quartz.dataSource.cpqrtz.maxConnections = 5
```

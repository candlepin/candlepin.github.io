---
layout: default
categories: usage
title: Configuring Candlepin to Use MySQL
---
{% include toc.md %}

# MySQL Tips for Developers
* Table names in MySQL are *case sensitive.*  This behavior can be adjusted as
  seen
  [here](http://dev.mysql.com/doc/refman/5.5/en/identifier-case-sensitivity.html)
  but it is best to assume that the DB will be case sensitive for table names.
  Consequently, make sure your @Table annotation matches your Liquibase
  createTable element.
* Prior to version 5.6.4, MySQL did not store fractions of a second in temporal
  data types. (See
  [here](http://dev.mysql.com/doc/refman/5.5/en/fractional-seconds.html)).  To
  be cross-database compatible then, we can not rely on straight comparisons of
  a new Date() to time values read from the database.  Instead we must make the
  time values coarser by rounding down to the nearest second.  You can use the
  following:

  ```java
  long now = new Date().getTime() / 1000;
  long someDBtime = foo.getTime() / 1000;
  if (now == someDBtime) {
  ...
  ```
* Additionally, since MySQL doesn't store fractions of a second, it may be
  necessary to insert a "sleep 1" in any spec test that is testing that
  something happened after something else.  Since the tests run so rapidly, it
  is possible that MySQL will record them as occurring in the same secord.
* String searches in MySQL are *case insensitive*.  See
  [here](http://dev.mysql.com/doc/refman/5.5/en/case-sensitivity.html).
* We are using DATETIME to store date information in MySQL.  In MySQL, DATETIME
  does not store any time zone information.  This is consistent with our
  Postgres and Oracle schemas which use TIMESTAMP WITHOUT TIME ZONE.  If we
  ever decide to store time zones, we have a couple of options.
  * Add a column to store the time zone.
  * Switch to TIMESTAMP which stores the value in UTC.  Note that the TIMESTAMP
    type can only store values up to the year 2038.  Additionally, MySQL has an
    annoying "feature" where the first TIMESTAMP column in a table is set to an
    automatic default and to be updated with the current time every time the
    record changes.  See
    [here](http://dev.mysql.com/doc/refman/5.5/en/timestamp-initialization.html).

# Running Candlepin on MySQL

## Getting Ready
1. Install MySQL with yum

   ```
   $ sudo yum install mysql-server mysql-connector-java
   ```
1. Enable MySQL with systemd

   ```
   $ sudo systemctl enable mysqld.service
   $ sudo systemctl start mysqld.service
   ```
1. Create the Candlepin user.

   ```
   mysql --user=root mysql --execute="CREATE USER 'candlepin'@'localhost';   GRANT ALL PRIVILEGES on candlepin.* TO 'candlepin'@'localhost' WITH GRANT OPTION"
   ```
1. Create the Candlepin database

   ```
   mysqladmin --user="candlepin" create candlepin
   ```

## Deploying
1. Add the necessary configuration to /etc/candlepin/candlepin.conf.  Make sure
   you comment out any options that might conflict with the options below!

   ```
   jpa.config.hibernate.connection.driver_class=com.mysql.jdbc.Driver
   jpa.config.hibernate.connection.url=jdbc:mysql:///candlepin
   jpa.config.hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect
   jpa.config.hibernate.connection.username=candlepin
   jpa.config.hibernate.connection.password=
   
   org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.StdJDBCDelegate
   org.quartz.dataSource.myDS.driver = com.mysql.jdbc.Driver
   org.quartz.dataSource.myDS.URL = jdbc:mysql:///candlepin
   org.quartz.dataSource.myDS.user = candlepin
   org.quartz.dataSource.myDS.password =
   org.quartz.dataSource.myDS.maxConnections = 5
   ```

1. Deploy to MySQL.

   ```
   $ buildconf/scripts/deploy -m
   ```

---
categories: developers
title: Debugging with LogDriver
---
# LogDriver
Hibernate has a great feature that will show the SQL statements which is some
what useful for debugging. To turn this on simply add set ['hibernate.show_sql
= true'](https://forum.hibernate.org/viewtopic.php?p=2401574). But the
Hibernate logging lacks a much needed feature, showing the parameter values of
the given SQL statement.  For this you need a logging JDBC driver that can
intercept the statements log the parameters then forward it off to the real
JDBC driver.

A few years ago a friend of mine wrote his own for a project we were working on
together: [jdbcLogDriver](http://sourceforge.net/projects/jdbclogdriver/). If
you want to use logdriver, there are just a few things you need to do.

Update your `$HOME/.candlepinrc` to know about logdriver, by adding the following:

```bash
LOGDRIVER=logdriver
```

That will configure the deploy script to pass in a buildr environment so it will know to
download the dependency and package it into the war.

If you are using [AutoConf](auto_conf.html) then candlepin.conf will now render candlepin.conf
to use the Logdriver.
{:.alert-notice}

Otherwise, you must perform the configuration yourself.  Start by changing your
JDBC driver class and url in `/etc/candlepin/candlepin.conf`:

```properties
jpa.config.hibernate.connection.driver_class=net.rkbloom.logdriver.LogDriver
jpa.config.hibernate.connection.url=jdbc:log:org.postgresql.Driver:postgresql:candlepin
```

Add logging statements to your config as well:

```properties
log4j.logger.net.rkbloom.logdriver.LogPreparedStatement=DEBUG
log4j.logger.net.rkbloom.logdriver.LogStatement=DEBUG
log4j.logger.net.rkbloom.logdriver.LogCallableStatement=DEBUG
log4j.logger.net.rkbloom.logdriver.LogConnection=DEBUG
```

That's it. You can now see all the nice PreparedStatement parameters
and see if a SQL call is actually being made :)

## Sample output
```
Jul 21 10:23:07 [main] DEBUG net.rkbloom.logdriver.LogPreparedStatement - executing PreparedStatement: 'call next value for seq_consumer' with bind parameters: {}
Jul 21 10:23:07 [main] DEBUG net.rkbloom.logdriver.LogPreparedStatement - executing PreparedStatement: 'insert into cp_consumer (created, updated, consumer_idcert_id, keyPair_id, name, owner_id, parent_consumer_id, type_id, username, uuid, id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' with bind parameters: {1=2010-07-21 10:23:07.603, 2=2010-07-21 10:23:07.603, 3=null, 4=null, 5=consumer name, 6=1, 7=null, 8=1, 9=testing user, 10=9052319d-c565-4ebc-ae4f-a0cc226271a4, 11=2}
Jul 21 10:23:07 [main] DEBUG net.rkbloom.logdriver.LogPreparedStatement - executing PreparedStatement: 'insert into cp_consumer_facts (cp_consumer_id, mapkey, element) values (?, ?, ?)' with bind parameters: {1=2, 2=name, 3=jsontestname}
```

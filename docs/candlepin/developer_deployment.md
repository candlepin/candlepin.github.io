---
categories: developers
title: Developer Deployment
---
{% include toc.md %}

# Simple Developer Deployment
The preferred method for deploying Candlepin from source is using the supplied
`deploy` script found in the `buildconf/scripts` directory. This script, when
properly configured, will generate the database schema, populate your
PostgreSQL database, create the certs for Tomcat6, deploy the war file, restart
tomcat.

Make sure you have the following packages installed which are required for a source deploy:

```console
$ sudo yum install postgresql-jdbc liquibase
```

By default the deploy script assumes tomcat6 installed via RPM. You can override this functionality by creating a `$HOME/.candlepinrc` file with some of the following entries:

GENDB=1
: if set, this enables schema generation and population (POSTGRES ONLY right now)

FORCECERT=1
: if set, will always regenerate new ssl certificates (both for the ca used in
creating client certificates, and for the server cert).

JBOSS_HOME
: set to the location of your jboss as installation, /opt/jboss-4.2.3.GA or
/var/lib/jbossas

TC_HOME
: set to the location of your tomcat installation, /opt/apache-tomcat-6.0.20 or
/var/lib/tomcat6 (default)

HOSTNAME
: use this to force the CN in your certificate. ie, set it to localhost if
you're only running a client from your machine.

TESTDATA=1
: if set, will load the candlepin db with sample data

LOGDRIVER=logdriver
: if set, will use the jdbc [logdriver](logdriver.html) for logging SQL calls

AUTOCONF=1
: if set, will use [AutoConf](auto_conf.html) to automatically generate `candlepin.conf`

NOTIFY=1
: if set, will use `notify-send` to notify you when deployment has finished

Here is my example `$HOME/.candlepinrc` file:

```bash
GENDB=1
TESTDATA=1
FORCECERT=1
```

Note: if you want to run using Tomcat in a different location, set `TC_HOME`
with the path where Tomcat is installed, e.g. `TC_HOME=/opt/apache-tomcat-6.0.20/`.

Before deploying Candlepin, be sure to setup your database. Once configured,
simply run the `deploy` script and watch magic happen.

```console
$ buildconf/scripts/deploy
```

**NOTE: you will need to set `FORCECERT=1` for the first run, to generate the
certs. If not, tomcat won't listen on port 8443.**

Note: Don't run the deploy script from the scripts directory but from the main directory as shown above.

Having trouble? Be sure to checkout the [Troubleshooting](#troubleshooting) section below.

# Don't like scripts?
The `deploy` script is the better way of publishing Candlepin, but if you just dislike
scripts that much you can do it manually. For more information see the [wiki:DeveloperDocs].

To build the .war manually:

```console
$ cd proxy
$ buildr clean test=no package
```

This should result in candlepin-XYZ.war file being created in the `target/` directory. Deploy the
resulting war file to your favorite [servlet container](#containers).

# Database
By default if Candlepin can not find its configuration file,
`/etc/candlepin/candlepin.conf`, it will deploy using an in-memory database
which will be destroyed and recreated on container restart.

To hit against a specific live database you must create a [configuration
file](configuration.html). **Be sure to use the right database username
and password.**

## Database Initialization
**IMPORTANT**: No matter which database you are using,  you will most likely
need to initialize it once and only once after it is created. This process
creates some core entries in the database required for Candlepin to operate
properly. If you are using our deploy script, this will be handled for you
automatically. Otherwise you can trigger this by hitting the following URL:

```console
$ wget -qO- http://localhost:8080/candlepin/admin/init
```

Repeated calls to this URL are not required, but will be harmless.

## PostgreSQL Tips
If you wish to test against PostgreSQL, install as follows:

1. Install Postgres.
   ```console
   $ sudo yum install -y postgresql-server postgresql
   ```

1. Once installed, you'll need to configure it. Initialize the db first.

   ```console
   $ sudo /sbin/service postgresql initdb
   ```
  
   **Note**: on Fedora 17, the above command fails with a response of "Unknown
   operation initdb". This is due to upstream changes in Postgresql. To initialize
   the DB run
   
   ```console
   $ sudo su - postgres -c "initdb -D /var/lib/pgsql/data"
   ```
   
   For more information on this topic please read [Bug 771496](https://bugzilla.redhat.com/show_bug.cgi?id=771496).

1. Update `/var/lib/pgsql/data/pg_hba.conf` to be trust instead of ident:

   ```
   # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
   local   all         all                               trust
   host    all         all         127.0.0.1/32          trust
   ```

1. Start the PostgreSQL server.

   ```console
   $ sudo /sbin/service postgresql start
   ```

1. Create the candlepin user:

   ```console
   $ sudo su - postgres -c 'createuser -dls candlepin'
   ```

# Containers

## Tomcat 6 (RPM based)

To deploy candlepin to [Tomcat](http://tomcat.apache.org/) 6 (RPM based), you
simply copy the war file into Tomcat's webapps directory.
On Fedora & RHEL, that is typically located at `/var/lib/tomcat6/webapps`.

```console
$ sudo /sbin/service tomcat6 stop
$ sudo cp target/candlepin-XYZ.war /var/lib/tomcat6/webapps/candlepin.war
$ sudo /sbin/service tomcat6 start
```

## Tomcat 6 (zip based)
The zip based [Tomcat](http://tomcat.apache.org/download-60.cgi) is almost
identical to the RPM based one except in the start/stop procedure and root
Tomcat location changes. The following assumes you installed Tomcat in `/opt`.

```console
$ /opt/apache-tomcat-6.0.20/bin/catalina.sh stop
$ sudo cp target/candlepin-XYZ.war /opt/apache-tomcat-6.0.20/webapps/candlepin.war
$ /opt/apache-tomcat-6.0.20/bin/catalina.sh start
```

## JBoss AS 4.2.3 (zip based)
For [JBoss AS](http://www.jboss.org/jbossas/downloads/), we simply copy the
`.war` file to the `deploy` directory.
In most cases you don't have to restart the appserver, but I like to do it. The following assumes
you installed JBoss in `/opt`.

```console
$ /opt/jboss-4.2.3.GA/bin/shutdown.sh
$ cp target/candlepin-XYZ.war /opt/jboss-4.2.3.GA/server/default/deploy/
$ /opt/jboss-4.2.3.GA/bin/run.sh
```

# Troubleshooting
There are a few things that some folks have hit while deploying Candlepin.

## Tomcat not listening on the right ports
If you see something amiss, an easy first thing to check is to ensure that
tomcat is running and listening on the right ports.

```console
# netstat -anlp | grep java
tcp        0      0 :::8080                     :::*                        LISTEN      21864/java          
tcp        0      0 :::8443                     :::*                        LISTEN      21864/java          
tcp        0      0 ::ffff:127.0.0.1:8005       :::*                        LISTEN      21864/java          
tcp        0      0 :::8009                     :::*                        LISTEN      21864/java          
unix  2      [ ]         STREAM     CONNECTED     793153 21864/java          
```

The important things here are 8080 (the default HTTP listener), and 8443 (the
SSL listener). If you don't have both of those, try setting FORCECERT=1 and
trying again. Consulting catalina.out is always useful as well.

## Tomcat fails to start
If you are getting errors trying to start and stop tomcat6 like:

```console
Stopping tomcat6: /etc/init.d/tomcat6: line 199: /var/log/tomcat6/catalina.out: Permission denied
java.io.FileNotFoundException: /usr/share/tomcat6/logs/localhost.2010-09-14.log (Permission denied)
java.io.FileNotFoundException: /usr/share/tomcat6/webapps/candlepin/META-INF/MANIFEST.MF (No such file or directory)
java.lang.RuntimeException: java.io.FileNotFoundException: /var/lib/candlepin/hornetq/bindings/hornetq-bindings-2.bindings (Permission denied)
```

you may need to manually find the files that tomcat6 can't access and do a 

```console
$ chown tomcat:tomcat <path>
```

until you can restart tomcat6 cleanly.

## HornetQ Upgrade Errors
The hornetq journal doesn't seem to like being used by new versions. If you see an exception on startup like: 

```console
SEVERE: Failure in initialisation
java.lang.IllegalStateException: Invalid record type 23
at org.hornetq.core.persistence.impl.journal.JournalStorageManager.loadBindingJournal(JournalStorageManager.java:1527)
```

You need to clear your journal:

```console
$ rm -rf /var/lib/candlepin/hornetq*
```

## buildr rspec conflicts
The latest version of rspec (2.0 or greater) will not work with
[buildr](http://buildr.apache.org) 1.4.3 and Candlepin. If you happen to have
the latest rspec and encounter errors like:

```console
$ buildconf/scripts/deploy
Buildr aborted!
Gem::LoadError : can't activate rspec (= 1.3.1, runtime) for [], already activated rspec-2.0.1 for ["buildr-1.4.3"]
/usr/lib/ruby/gems/1.8/gems/buildr-1.4.3/lib/buildr/core/application.rb:215:in `load_buildfile'
/usr/lib/ruby/gems/1.8/gems/buildr-1.4.3/lib/buildr/core/application.rb:213:in `load_buildfile'
(See full trace by running task with --trace)
```

you would need to patch `/usr/bin/buildr` with the following patch

```diff
--- buildr	2010-10-27 15:37:49.059047616 -0400
+++ buildr	2010-11-01 14:33:30.855332904 -0400
@@ -7,7 +7,7 @@
 #
 
 require 'rubygems'
-
+gem 'rspec', '1.3.1'
 version = ">= 0"
 
 if ARGV.first =~ /^_(.*)_$/ and Gem::Version.correct? $1 then
```

# How do I know if this is working?
Head into the candlepin/client/ruby dir, and run this:

```console
$ ./cpc list_products
```

If you get a bunch of output, you are all set. Note that you can't test candlepin via telnet, since it uses 8443 for most calls.

# Analyzing PostgreSQL Performance
```sql
CREATE FUNCTION pg_temp.sortarray(int2[]) returns int2[] as '
  SELECT ARRAY(
      SELECT $1[i]
        FROM generate_series(array_lower($1, 1), array_upper($1, 1)) i
    ORDER BY 1
  )
' language sql;
 
  SELECT conrelid::regclass
         ,conname
         ,reltuples::bigint
    FROM pg_constraint
         JOIN pg_class ON (conrelid = pg_class.oid)
   WHERE contype = 'f'
         AND NOT EXISTS (
           SELECT 1
             FROM pg_index
            WHERE indrelid = conrelid
                  AND pg_temp.sortarray(conkey) = pg_temp.sortarray(indkey)
         )
ORDER BY reltuples DESC
;
```

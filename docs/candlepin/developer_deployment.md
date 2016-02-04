---
categories: developers
title: Developer Deployment
---
{% include toc.md %}

# Developer Deployment

## Getting the Source

You can browse the source code at <https://github.com/candlepin/candlepin/>.

For anonymous access to the Candlepin source code, feel free to clone the repository:

```console
$ git clone git://github.com/candlepin/candlepin.git
```

Candlepin committers can clone the repository using the ssh url, which is
required if you want to push changes into the repo (and of course you need
permission to do so).

```console
$ git clone git@github.com:candlepin/candlepin.git
```

For more information on working with Git, checkout the [Spacewalk](https://fedorahosted.org/spacewalk/) [GitGuide](https://fedorahosted.org/spacewalk/wiki/GitGuide).

## Install Dependencies

Instructions for Fedora 22.

Candlepin uses [buildr](http://buildr.apache.org) as its build tool
(primarily because we don't like maven).

* Install dependencies.

  ```console
  $ sudo dnf install ruby rubygems ruby-devel gcc make gettext tomcat java-1.8.0-openjdk-devel liquibase postgresql-jdbc openssl libxml2-python
  ```

  NOTE: You may want to install Java 1.6.0 or 1.7.0 depending on OS version.
  {:.alert-bad}

* Update rubygems.

  ```console
  $ sudo gem update --system
  ```

* Become root.

  ```console
  $ sudo -s
  ```

* Set `JAVA_HOME`

  ```console
  # export JAVA_HOME=/usr/lib/jvm/java-1.8.0/
  ```

  NOTE: This should match the Java version specified above.
  {:.alert-bad}

* Install bundler.

  ```console
  # gem install bundler
  ```

* Return to your normal user account and candlepin.git checkout.
* Install the Ruby dependencies.

  ```console
  $ bundle install
  ```

Make sure your tomcat directory within /var/cache has group permissions (`chmod 775 /var/cache/tomcat`)
{:.alert-caution}

## Compiling

If you have multiple JVMs on your system and are getting `RuntimeError : can't
create Java VM`, you may need to set your JVM via `alternatives --config java`
and `alternatives --config javac`. Additionally, you may need to use this
JAVA_HOME path: `/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.**.x86_64/`, where the ** should be filled in
with the appropriate build version (matching the proper directory from `ls /usr/lib/jvm/`).

The following will compile and package candlepin into a war and api jar in `target/`.
Testing will be covered below hence the `test=no` param.

```console
$ cd candlepin/
$ buildr clean test=no package
```

## Configure A Database

Candlepin is typically deployed against PostgreSQL, but schema is provided for Oracle and MySQL as well.

### PostgreSQL

1. Install PostgresSQL.

   ```console
   $ sudo dnf install -y postgresql-server postgresql
   ```

1. Initialize PostgreSQL.

   ```console
   $ sudo postgresql-setup initdb
   ```

1. Update `/var/lib/pgsql/data/pg_hba.conf` to be trust instead of ident:

   ```
   # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
   local   all         all                               trust
   host    all         all         127.0.0.1/32          trust
   host    all         all         ::1/128               trust
   ```

1. Enable and start the PostgreSQL server.

   ```console
   $ sudo systemctl enable postgresql
   $ sudo systemctl start postgresql
   ```

1. Create the candlepin user:

   ```console
   $ sudo su - postgres -c 'createuser -dls candlepin'
   ```

## Deploy Candlepin

The preferred method for deploying Candlepin from source is using the
supplied `deploy` script in the `server/bin` directory. This script will generate
the database schema, populate your PostgreSQL database, create the certs
for Tomcat, deploy the war file, and restart tomcat. It can also be used to deploy to a Oracle/MySQL databases, and pre-load our test data.

Remember to set JAVA_HOME for buildr to work.
{:.alert-caution}

```console
$ server/bin/deploy
```

Test that the application is listening with:

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/status"
```

### Deploy Script Options

The deploy script can be customized with a number of environment variables, or you can set these permanently in ```~/.candlepinrc```.

#### Environment Variables

GENDB=1
: if set, this enables schema generation and population. Can also be achieved with the `-g` argument to deploy script.

FORCECERT=1
: if set, will always regenerate new ssl certificates (both for the ca used in creating client certificates, and for the server cert). Can also be achieved with the `-f` argument to the deploy script.

HOSTNAME
: use this to force the CN in your certificate. ie, set it to localhost if you're only running a client from your machine.

TESTDATA=1
: set to 1 to automatically load our test data as defined in ```server/bin/test_data.json```. This is a selection of product, subscription, and org info that nicely covers all the functionality of Candlepin. Subscriptions point to fake content however and thus cannot be used with an actual client. Can also be specified with the `-t` argument to the deploy script.

LOGDRIVER=logdriver
: if set, will use the jdbc [logdriver](logdriver.html) for logging SQL calls. This can also be specified with the `-l` argument to the deploy script.

AUTOCONF=1
: if set, will use [AutoConf](auto_conf.html) to automatically generate `candlepin.conf`. Can also be specified with the `-a` argument to the deploy script.

NOTIFY=1
: if set, will use `notify-send` to notify you when deployment has finished

TC_HOME
: set to the location of your tomcat installation, /opt/apache-tomcat-6.0.20 or /var/lib/tomcat (default).

HOSTEDTEST=
hostedtest
: if set, includes the resources for testing candlepin in hosted mode. Can also be specified with the `-H` argument to the deploy script. If used with `AUTOCONF`, the default adapters will be overriden by hostedtest adapters in `candlepin.conf`

#### Script Arguments
The deploy script may also be customized/configured by providing command-line arguments during invocation. Some of these overlap with those triggered by environment variables, providing shorter alternatives to triggering the options above.

-f
: Alternate to the FORCECERT variable. If set, the deploy script will generate new SSL certificates.

-g
: Alternate to the GENDB variable. If set, the current database, if any, will be dropped and a new schema will be generated.

-t
: Alternate to the TESTDATA variable. If set, the database will be populated with the test data defined in ```server/bin/test_data.json``` after a successful deployment.

-l &lt;log_driver&gt;
: Alternate to the LOGDRIVER variable. If set, Candlepin will use the specified log driver for logging SQL calls.

-o, -m
: Specifies alternate database backends to use instead of PostgreSQL; `-o` for Oracle and `-m` for MySQL. Only one alternate should be specified for a given invocation.

-a
: Alternate to the AUTOCONF variable. If set, [AutoConf](auto_conf.html) will be used to automatically generate a new `candlepin.conf` file.

-v
: Enabled verbose/noisy output. Useful, primarily, for debugging issues that may arise during deployment.

-H
: Alternate to the HOSTEDTEST variable. If set, resources to test candlepin in hosted mode will be included in the candlepin war. If used with `-a`, the default adapters will be overriden by hostedtest adapters in `candlepin.conf`


### Manual Deployment

If for some reason you wish to deploy manually, you can generate the candlepin war file and deploy it into tomcat easily.

```console
$ buildr clean test=no package
```

This should result in candlepin-XYZ.war file being created in the `target/` directory. Deploy the resulting war file to your favorite servlet container.

# Troubleshooting

There are a few things that some folks have hit while deploying Candlepin.

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


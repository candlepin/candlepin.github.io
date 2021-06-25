---
title: Developer Deployment
---
{% include toc.md %}

# Developer Deployment

## Operating System
Any flavor of Linux should be acceptable for development, but all of the instructions below are written
for Fedora 34. You may need to make slight changes to the package names, depending on what is available
from your system's package manager and repositories.

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


## Vagrant
Candlepin provides a Vagrant box for creating a virtualized development environment. This is the recommended
way to do work on Candlepin, as it helps ensure everyone is working with the same the development environment.

### Setup

1. Install Vagrant and its dependencies
    ```console
    $ sudo dnf install vagrant vagrant-libvirt vagrant-hostmanager vagrant-sshfs ansible python3-netaddr
    ```

1. Bring up the Vagrant box
    ```console
    $ vagrant up
    ````

    This will run through the process of starting the virtual machine, creating it as necessary, and provisioning
    the box with Ansible. On first run, this step may take some time, and may appear unresponsive at some steps.
    However, later runs will bring the box up very quickly.

1. SSH into the Vagrant box
    ```console
    $ vagrant ssh
    ```

    This will drop you into a shell at the root directory. The local Candlepin from which the Vagrant box was
    built has been synced into `/vagrant`. At this point, Candlepin can be deployed following the instructions
    in the [Deploying Candlepin](#deploying-candlepin) section.

### Post-setup Steps

Note that while Vagrant makes setting up the environment easier, it comes with some caveats:

* SSH keys and Git configuration are not copied into the Vagrant box

    You will need to manually configure your git e-mail address and name in the Vagrant box, as well as copy
    any SSH keys in to be able to properly commit and push changes from within the box. This step may be
    omitted, but you will be forced to drop out of the Vagrant box to commit or push changes.

* MariaDB is not installed by default

    At the time of writing, the provisioning step does not install or configure MariaDB/MySQL. This
    must be done manually, following the steps outlined in the [Set up MariaDB/MySQL](#set-up-mariadb-mysql)
    section.

* Java 11 is not installed by default

    Like the above, Java 11 is not currently installed as part of the provisioning step. This can be done
    by issuing the command manually:

    ```console
    $ sudo dnf install java-11-openjdk-devel
    ```

    Then, update the JAVA_HOME environment variable export in `~/.bashrc` and `/etc/tomcat/tomcat.conf` to
    point to the directory managed by Alternatives: `/var/lib/java/jvm`

    Finally, Alternatives can be used to specify which version of `java` and `javac` are needed:

    ```console
    $ sudo alternatives --config java
    $ sudo alternatives --config javac
    ```

These steps only need to be performed after initially bringing up the box for the first time, or if the box
is ever recreated after destroying it.

These will eventually be resolved in future versions of the Ansible roles responsible for provisioning the
Vagrant boxes.



## Local Development
If you are unable or unwilling to use the Vagrant box for development tasks, you can, instead, set up your
local environment for Candlepin development. Note that some Candlepin dependencies may not be available from
your system's package manager and/or may conflict with those that are. In such cases, you will need to
manually resolve the conflict.

1. **Install and configure core dependencies**

    ```console
    $ sudo dnf install gcc make java-1.8.0-openjdk-devel java-11-openjdk-devel jss tomcat gettext openssl
    ```
    By default, the JAVA_HOME environment variable is not setup during this install. This should be configured
    to point to the home directory for the "active" JVM (Java 11 in most cases, Java 8 for some older
    Candlepin branches).

    On systems where Alternatives is available and configured (as is the case on Fedora 34), this should point
    to the Alternatives-managed JDK directory:

    ```console
    $ echo 'export JAVA_HOME="/var/lib/jvm/java"' >> ~/.bashrc
    ```

    If Alternatives is not installed or enabled, JAVA_HOME will need to be configured to point to the explicit
    JDK directory as needed.


1. **Install Ruby and Ruby gems**

    Candlepin currently requires Ruby 2.4 to run its spec test suite (rspec), which is unfortunately
    no longer available through the standard package repos in Fedora 34. For this reason, and to avoid
    conflicts with various gems, we highly recommend using [RVM](http://rvm.io) to install and manage Ruby
    and its gems.

    Instructions for installing RVM are available on the [RVM](http://rvm.io) website (<http://rvm.io>).

    Warning: Do not install RVM, Ruby, or the necessary gems as root
    {:.alert-bad}

    Once RVM is installed, install Ruby 2.4 via rvm:

    ```console
    $ rvm install ruby-2.4
    ```

    Finally, install bundler so we can install the required gems:

    ```console
    $ gem install bundler
    $ bundle install
    ```


1. **Set up PostgreSQL**

    PostgreSQL is the recommended database solution for Candlepin. PostgreSQL 9.6 is required at minimum, but
    newer versions are also supported and recommended.

    * Install PostgreSQL server, client and the JDBC connector

        ```console
        $ sudo dnf install postgresql-server postgresql postgresql-jdbc
        ```

    * Initialize the database

        ```console
        $ sudo postgresql-setup --initdb --unit postgresql
        ```

    * Configure PostgreSQL to trust local connections

        Open `/var/lib/pgsql/data/pg_hba.conf` in a text editor and change the local connection methods
        to be "trust.":

        ```
        # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
        local   all         all                               trust
        host    all         all         127.0.0.1/32          trust
        host    all         all         ::1/128               trust
        ```

        Note: This is not advised on a production or external-facing environment. For such environments,
        this file should be configured to allow local connections to the "candlepin" database from the
        "candlepin" user. Exactly what this configuration will look like may vary depending on the
        requirements of the environment.
        {:.alert-caution}

    * Enable and start the postgresql service

        ```console
        $ sudo systemctl enable postgresql.service
        $ sudo systemctl start postgresql.service
        ```

    * Create the `candlepin` user

        ```console
        $ sudo su - postgres -c 'createuser -dls candlepin'
        ```

    * Create the `candlepin` database

        ```console
        $ createdb --user candlepin candlepin
        ```


1. **Set up MariaDB/MySQL**

    In addition to PostgreSQL, Candlepin also supports using MariaDB or MySQL databases, so both must be
    available for testing purposes.

    * Install MariaDB server, MariaDB, and the JDBC connector

        ```console
        $ sudo dnf install mariadb-server mariadb mysql-connector-java
        ```

    * Add the Candlepin-specific server configuration

        Create the file `/etc/my.cnf.d/candlepin.cnf` and the following:

        ```
        [mysqld]
        collation-server=utf8_general_ci
        character-set-server=utf8

        transaction-isolation=READ-COMMITTED
        ```

    * Set the default time zone

        Open `/etc/my.cnf.d/mariadb-server.cnf` in a text editor and add the following under `[server]`:

        ```
        default-time-zone="+00:00"
        ```

    * Enable and start the mariadb service

        ```console
        $ sudo systemctl enable mariadb.service
        $ sudo systemctl start mariadb.service
        ```

    * Create the `candlepin` user and its necessary permissions

        ```console
        $ sudo mysql --user=root mysql --execute="CREATE USER 'candlepin'@'localhost'; GRANT ALL PRIVILEGES on candlepin.* TO 'candlepin'@'localhost' WITH GRANT OPTION;"
        ```

    * Create the `candlepin` database

        ```console
        $ mysqladmin --user candlepin create candlepin
        ```

At this point, Candlepin can be deployed following the instructions in the
[Deploying Candlepin](#deploying-candlepin) section.


## Deploying Candlepin
The preferred method for deploying Candlepin from source is using the supplied `deploy` script in the
`bin/deployment` directory. This script will generate the database schema, create the necessary certificates
for Tomcat, deploy the .war file, and restart Tomcat. It can also be used to generate candlepin.conf or
generate data for manual testing.

Note: Older Candlepin branches may store the deploy script in `server/bin/` instead.
{:.alert-caution}

For the first deployment, or whenever changing databases, it is recommended to use the `-a` option to
regenerate the candlepin.conf file for the new environment. The `-g` flag can also be specified to tell
the deploy script to drop the database (if it exists) and regenerate it.

```console
$ ./bin/deployment/deploy -g -a
```

By default, the deploy script will target PostgreSQL, however, the `-m` flag can be set to target
MariaDB/MySQL instead:

```console
$ ./bin/deployment/deploy -g -m -a
```

For a typical redeployment once the environment has already been configured, no flags or options need to be
provided. This will simply recompile and deploy Candlepin without changing the configuration or dropping the
existing database.

```console
$ ./bin/deployment/deploy
```

A full listing of the options available can be viewed by using `-h` or `--help` with the command:

```console
$ ./bin/deployment/deploy -h
usage: deploy [options]

OPTIONS:
  -f          force cert regeneration
  -g          generate database
  -r          generate test repositories
  -t          import test data
  -T          import minimal test data, some owners, users, and roles
  -H          include test resources for hosted mode
  -l          use Logdriver
  -m          use MySQL
  -a          auto-deploy a generated candlepin.conf
  -v          verbose output
  -d <name>   specify a database name to use when creating or updating the Candlepin database
  -b          deploy candlepin with an external Artemis message broker
```

Note: The above output may differ from the options available in your working branch.
{:.alert-caution}

After running the deploy script, you can verify Candlepin is running by testing the "status" endpoint:

```console
$ curl -k "https://localhost:8443/candlepin/status"
```

If Candlepin is running properly, this will return a block of JSON data describing Candlepin's current state
and some capabilities:

```console
{
  "mode" : "NORMAL",
  "modeReason" : null,
  "modeChangeTime" : null,
  "result" : true,
  "version" : "4.1.1",
  "release" : "1",
  "standalone" : true,
  "timeUTC" : "2021-06-25T19:08:39+0000",
  "rulesSource" : "default",
  "rulesVersion" : "5.43",
  "managerCapabilities" : [ "instance_multiplier", "derived_product", "vcpu", "cert_v3", "hypervisors_heartbeat", "remove_by_pool_id", "syspurpose", "storage_band", "cores", "hypervisors_async", "org_level_content_access", "guest_limit", "ram", "batch_bind" ],
  "keycloakRealm" : null,
  "keycloakAuthUrl" : null,
  "keycloakResource" : null
}
```


# Running Tests

Candlepin provides two tests suites for proper functionality and stability: unit tests and specification
tests, via JUnit and rspec, respectively. Whenever changes are made to Candlepin, both of these suites
should be run to verify existing functionality has not be affected by the changes, and new tests should be
added to each suite as appropriate for the change.

## Unit tests

Unit testing is provided by JUnit, and can be invoked through Gradle with the `test` task from the root
of the Candlepin repository.

```console
$ ./gradlew test
```

This will run the entire unit test suite, and write the results in HTML form to the build directory. To run
tests for a specific suite of tests, the `--tests` option can be used with the class name of the suite to
run.

For example, to run the tests in the JobManagerTest class, the following command can be used:

```console
$ ./gradlew test --tests JobManagerTest
```

Lastly, an individual test in a given suite can be run using the name of the method, following Java
dot-notation:

```console
$ ./gradlew test --tests "JobManagerTest.jobStatusFound"
```

## Specification Tests

Specification tests are run through rspec, and can be invoked through Gradle with the `rspec` task from the
root of the Candlepin repository.

```console
$ ./gradlew rspec
```

This will run  the entire spec test suite, and write the results to the console. To run tests for a specific
spec test suite, the `--spec` option can be used with the partial file name of the spec file to run, without
the "_spec.rb" suffix.

For example, to run the tests in the activation_key_spec.rb file, the following command can be used:

```console
$ ./gradlew rspec --spec activation_key
```

Individual tests or groups of tests within a given spec file can be run using the `--test` option and
providing a string to match against the name of the desired tests.

For instance, to run the tests in the activation_key_spec file containing the word "updating", the following
command can be used:

```console
$ ./gradlew rspec --spec activation_key --test 'updating'
```


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


---
title: Setting Up Candlepin
---
{% include toc.md %}

# Candlepin Setup

This page describes how to install Candlepin using the rpms. If you are building from source, please
see [wiki:Deployment].

# PostgreSQL

1. Install PostgresSQL.

   ```console
   $ sudo yum install -y postgresql-server postgresql
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
   ```

1. Enable and start the PostgreSQL server.

   ```console
   $ sudo chkconfig postgresql on
   $ sudo /sbin/service postgresql start
   ```

# Candlepin

1. Configure the yum repo,

   ```console
   $ wget -O /etc/yum.repos.d/fedora-candlepin.repo http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-candlepin.repo 
   ```

   **OR**

   ```console
   $ wget -O /etc/yum.repos.d/epel-candlepin.repo http://repos.fedorapeople.org/repos/candlepin/candlepin/epel-candlepin.repo
   ```
1. Install Candlepin

   ```console
   $ sudo yum install candlepin-tomcat6
   ```

1. Make sure you have OpenJDK 1.6 java configured as the default system-wide
   java platform using `java -version`. If not set it as the default:

   ```console
   $ sudo update-alternatives --config java
   ```

1. Create the candlepin user:

   ```console
   $ sudo su - postgres -c 'createuser -dls candlepin'
   ```

1. Setup candlepin

   ```console
   $ sudo /usr/share/candlepin/cpsetup
   ```

1. Verify Candlepin is running:

   ```console
   $ curl -k -u admin:admin https://localhost:8443/candlepin/status
   ```

# Troubleshooting
For the most part, `cpsetup` should JUST WORK (TM), here is an example of a *successful* run of `cpsetup`:

```console
# /usr/share/candlepin/cpsetup
Dropping candlepin database
Creating candlepin database
Loading candlepin schema
Writing configuration file
Creating CA private key password
Creating CA private key
Creating CA public key
Creating CA certificate
Waiting for tomcat to restart...
Candlepin has been configured.
```

There are occasions where you might run into some problems. Below is a set of common problems you might experience.

## PostgreSQL isn't running

If you see this error:

```text
Dropping candlepin database

########## ERROR ############
Error running command: dropdb -U candlepin candlepin
Status code: 256
Command output: dropdb: could not connect to database postgres: could not connect to server: 
```
{:.output-only}
<!--
  These error message blocks are marked as text because if they were marked as 'console', Pygments
  would interpret the hash mark as a prompt and highlight it incorrectly.  We use the .output-only
  class to get the highlighting correct.
-->

then start PostgreSQL:

```console
$ sudo /sbin/service postgresql start
```

## PostgreSQL user does not exist

If you see this error:

```text
########## ERROR ############
Error running command: dropdb -U candlepin candlepin
Status code: 256
Command output: dropdb: could not connect to database postgres: FATAL:  Ident authentication failed for user "candlepin"
```
{:.output-only}

then create the PostgreSQL user:

```console
$ sudo su - postgres -c 'createuser -dls candlepin'
```

## Candlepin database being used by another process
Sometimes re-running `cpsetup` might result in the following error meaning that
either the user is logged into the database using a database client i.e. `psql`
or candlepin application is still running (most likely).

```text
Dropping candlepin database

########## ERROR ############
Error running command: dropdb -U candlepin candlepin
Status code: 256
Command output: dropdb: database removal failed: ERROR:  database "candlepin" is being accessed by other users
DETAIL:  There are 1 other session(s) using the database.
```
{:.output-only}

Most of the time this is a result of the candlepin webapp still running, restart tomcat

```console
$ sudo /sbin/service tomcat6 stop
```

If you are using a database client, quit the database client.

```psql
candlepin=# \q
```

## PostgreSQL not configured for trust
Candlepin currently expects that the database is configured in trust mode (i.e.
no password required).  If you see the following error, please check the
[PostgreSQLTips](developer_deployment.html#postgresql-tips) for help.

```text
Dropping candlepin database

########## ERROR ############
Error running command: dropdb -U candlepin candlepin
Status code: 256
Command output: dropdb: could not connect to database postgres: FATAL:  Ident authentication failed for user "candlepin"
```
{:.output-only}

## Wrong Java version and incorrect tomcat6 permissions
tomcat6 installs java-1.5.0-gcj instead of java-1.6.0-openjdk and sets some
incorrect permissions which may lead to the following error during cpsetup:

```text
########## ERROR ############
Error running command: wget -qO- http://localhost:8080/candlepin/admin/init
Status code: 2048
Command output:
Traceback (most recent call last):
  File "/usr/share/candlepin/cpsetup", line 215, in <module>
    main(sys.argv[1:])
  File "/usr/share/candlepin/cpsetup", line 207, in main
    run_command("wget -qO- http://localhost:8080/candlepin/admin/init")
  File "/usr/share/candlepin/cpsetup", line 34, in run_command
    raise Exception("Error running command")
Exception: Error running command
```
{:.output-only}

Please make sure that you have installed java-1.6.x-openjdk and check if
permissions are correct for tomcat6, as noted in [Red Hat Bugzilla
708694](https://bugzilla.redhat.com/show_bug.cgi?id=708694)

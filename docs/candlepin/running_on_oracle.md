---
title: Configuring Candlepin to Use Oracle
---
{% include toc.md %}

# Oracle Tips For Developers
* Everything must be less than 30 characters long.  This restriction includes table names, column names, indexes, foreign keys, etc.
* Liquibase scripts must be written with Oracle in mind.
   * If a script is using a PostgreSQL datatype (e.g. bytea or boolean), make sure to mark the changeSet with the dbms="postgresql" attribute.  Create a corresponding changeSet for Oracle and mark it with dbms="oracle".
   * It is possible to define properties differently based on the database type.  For example

     ```xml
     <property name="blob.type" value="blob" dbms="oracle"/>
     <property name="blob.type" value="bytea" dbms="postgresql"/>
     [...]
     <column name="foo" type="${blob.type}"/>
     ```
* To make using SQLPlus bearable, yum install rlwrap and preface your SQLPlus command with "rlwrap".  This will add GNU readline support to SQLPlus so things like the up arrow will show your previous command.  For example,

  ```console
  $ rlwrap sqlplus 'sys/password@//localhost/XE as sysdba'
  ```

# Running Candlepin on Oracle
This article is for developers interested in running Candlepin with an Oracle back-end.

Commands prefaced with a "#" are meant to be run as root. Those prefaced
with a "$" are meant to be run as an ordinary user.
{:.alert-notice}

## Getting Ready

1. Download Oracle 11g Express Edition (XE) Server from
   <http://www.oracle.com/technetwork/products/express-edition/downloads/index.html>
1. Download Oracle Instant Client from <http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html>
   * You will need oracle-instantclient11.2-basic and oracle-instantclient11.2-sqlplus
1. Create the Oracle user and DBA group.  Note the -u in the useradd command.
   That creates a system account with a uid less than 500.  **This is important.**
   The SELinux packages from Spacewalk will not install if the Oracle user has
   a UID greater than 500.  I put 499 in the example below, but you may need to
   use a different value if that UID conflicts with an existing one.

   ```console
   # /usr/sbin/groupadd -r dba
   # /usr/sbin/useradd -r -M -g dba -d /u01/app/oracle -s /bin/bash -u 499 oracle
   ```
1. Make sure you have > 1GB of swap.

   ```console
   # free -m
   ```
1.  Ensure your hostname is resolvable either with DNS or with an entry in
    /etc/hosts. Otherwise, the configuration of the Oracle Net Listener will
    fail.

## Installation
Now it is time to begin the installation.

1. Install bc as it is a dependency that isn't automatically resolved.

   ```console
   # yum install -y bc
   ```
1. Install Oracle XE

   ```console
   # yum localinstall -y --nogpgcheck oracle-xe-11.2.0-1.0.x86_64.rpm
   ```
1. Install the instant client.

   ```console
   # yum localinstall -y --nogpgcheck oracle-instantclient11.2-basic*.rpm oracle-instantclient11.2-sqlplus*.rpm
   ```
1. We will need the Oracle SELinux packages developed by Spacewalk.

   ```console
   # yum install -y http://yum.spacewalkproject.org/1.9/RHEL/6/x86_64/spacewalk-repo-1.9-1.el6.noarch.rpm
   ```
1. Install the SELinux packages

   ```console
   # yum install -y oracle-xe-selinux oracle-instantclient-selinux oracle-instantclient-sqlplus-selinux
   ```

## Configuration
1. Run the Oracle configuration script.

   ```console
   # cd / && /etc/init.d/oracle-xe configure
   ```
1. Set the values asked for by the configuration script as follows: (Note that
   our deploy script assumes the password is the string "password".)

   ```
   HTTP port for Oracle Application Express: 9055
   Database listener port: 1521
   Password for SYS/SYSTEM: password
   Start at boot: y
   ```
   {:.output-only}
1. Make sure you can connect locally.

   ```console
   # sqlplus 'sys/password@//localhost/XE as sysdba'
   ```
1. You may need to poke a hole in your firewall for port 1521 if you plan on
   connecting to Oracle from a different machine.  Edit
   /etc/sysconfig/iptables and add

   ```
   -A INPUT -m state --state NEW -m tcp -p tcp --dport 1521 -j ACCEPT
   ```

   or with firewalld

   ```console
   # firewall-cmd --add-port=1521 --permanent
   # firewall-cmd --reload
   ```
1. Or for temporary purposes you can use

   ```console
   # iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 1521 -j ACCEPT
   ```

   or with firewalld

   ```console
   # firewall-cmd --add-port=1521
   ```
1. You will need to make some SELinux changes to get SQL*Plus to be able to
   read a SQL script from the file system.  I have not hit upon the right
   combination of policies yet, so for the moment simply disable SELinux for
   the Oracle domain.

   ```console
   # semanage permissive -a oracle_sqlplus_t
   ```
1. You can attempt to devise the correct policy using `audit2allow`, but I was unable to get everything working.

## Running Candlepin
1. Download the JAR file from <http://www.oracle.com/technetwork/database/enterprise-edition/jdbc-112010-090769.html>
1. Install the JAR file into your Maven repository.

   ```console
   # yum install maven
   $ mvn install:install-file -Dfile=ojdbc6.jar -DgroupId=com.oracle -DartifactId=ojdbc6 -Dversion=11.2.0 -Dpackaging=jar
   ```
   
   Or for those maven haters:
   
   ```console
   $ mkdir -p $HOME/.m2/repository/com/oracle/ojdbc6/11.2.0
   $ cp ojdbc6.jar $HOME/.m2/repository/com/oracle/ojdbc6/11.2.0/ojdbc6-11.2.0.jar
   ```
1. Add the necessary Oracle configuration information to /etc/candlepin/candlepin.conf.

   ```properties
   jpa.config.hibernate.connection.driver_class=oracle.jdbc.OracleDriver
   jpa.config.hibernate.connection.url=jdbc:oracle:thin:@//localhost:1521/XE
   jpa.config.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect
   jpa.config.hibernate.connection.username=candlepin
   jpa.config.hibernate.connection.password=candlepin
   ```

   If you are using [AutoConf](auto_conf.html), it will take care of this for you.
   {:.alert-notice}
1. Make sure to remove or comment out the PostgreSQL configuration.
1. If you are running with the LogDriver, the first two lines will look like this instead:

   ```properties
   jpa.config.hibernate.connection.driver_class=net.rkbloom.logdriver.LogDriver
   jpa.config.hibernate.connection.url=jdbc:log:oracle.jdbc.OracleDriver:oracle:thin:@//localhost:1521/XE
   ```
1. If you are using Quartz with DB, you'll also need to update these entries:

   ```properties
   org.quartz.jobStore.dataSource = myDS
   org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.oracle.OracleDelegate
   org.quartz.dataSource.myDS.driver = oracle.jdbc.OracleDriver
   org.quartz.dataSource.myDS.URL = jdbc:oracle:thin:@//localhost:1521/XE
   org.quartz.dataSource.myDS.user = candlepin
   org.quartz.dataSource.myDS.password = candlepin
   ```
1. Now you are ready to deploy to Oracle!  The -o option tells the script to
   compile with the Oracle JDBC driver and run Liquibase against Oracle and
   the -g option tells Liquibase to generate a new database.  You can also use
   USE_ORACLE and GENDB in your ~/.candlepinrc file.

   ```console
   $ DBPASSWORD=candlepin buildconf/scripts/deploy -o -g
   ```
   
   A non-default database password can be supplied with the DBPASSWORD environment
   variable.
   {:.alert-notice}

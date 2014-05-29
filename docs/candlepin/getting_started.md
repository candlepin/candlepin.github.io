---
categories: developers
title: Developer's Guide to Getting Started
---
{% include toc.md %}

# Getting started
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

# The Code
 * [Coding Conventions (style)](java_coding_conventions.html)
 * [Coding Standards](developer_notes.html#code-style)
 * [Testing Standards](developer_notes.html#testing)

# Building

## Prerequisites
Candlepin uses [buildr](http://buildr.apache.org) as its build tool (primarily
because we don't like maven).
For building on Fedora 17, you will need: java, tomcat6, gettext, and [buildr](http://buildr.apache.org/).

* Install dependencies.

  ```console
  $ sudo yum install ruby rubygems ruby-devel gcc perl-Locale-Msgfmt tomcat6 java-1.7.0-openjdk-devel liquibase postgresql-jdbc
  ```

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
  # export JAVA_HOME=/usr/lib/jvm/java-1.7.0/
  ```
  
  WARNING: you may want 1.6.0 depending on OS version
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

For other options, check the [buildr site](http://buildr.apache.org/installing.html).

Make sure your tomcat6 directory within /var/cache has group permissions (`chmod 775 /var/cache/tomcat6`)
{:.alert-caution}

## Compiling

Remember to set JAVA_HOME for buildr to work.
{:.alert-caution}

If you have multiple JVMs on your system and are getting `RuntimeError : can't
create Java VM`, you may need to set your JVM via `alternatives --config java`
and `alternatives --config javac`. Additionally, you may need to use this
JAVA_HOME path: `/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64/`

The following will compile and package candlepin into a war and api jar in `target/`.
Testing will be covered below hence the `test=no` param.

```console
$ cd candlepin/
$ buildr clean test=no package
```

## Testing
Candlepin has two test suites, a set of unit tests and functional tests. The unit
tests will run from source against an in-memory database, while the functional tests
expect a deployed Candlepin to test its functionality.

To run the unit tests simply run:

```console
$ buildr test
```

Additionally there is a suite of functional tests which require a deployed
Candlepin instance to hit against. For more information on deploying Candlepin
see: [Deployment](developer_deployment.html)

These tests currently assume they can hit http://localhost:8080/candlepin/

To run the functional tests, from the root of the git checkout or the `test/` directories, run:

```console
$ buildr spec
```

Functional tests can take a while to run. You can speed up the process by running them in parallel.

```console
$ buildr parallel_rspec
```

# Other

## Eclipse Setup
The Candlepin buildfile has an eclipse task to generate the `.classpath` for you.

* Generate the .classpath file first:

  ```console
  $ cd candlepin/
  $ buildr eclipse
  (in /home/user/devel/candlepin, development)
  Generating Eclipse project for candlepin
  Writing /home/user/devel/candlepin/.classpath
  Writing /home/user/devel/candlepin/.project
  Fixing eclipse .classpath
  Completed in 0.180s
  ```
* Create a Java project as you normally would (File -> New -> Java Project).
* Choose Create Project From Existing Source.
* Choose the root of your git checkout.
* Ensure your `M2_REPO` classpath variable is pointing to `~/.m2/repository`

## Tomcat Setup under Eclipse
 * Install Java EE Developer Tools, JST Server Adapters, JST Server UI from Web, XML and Java EE Development Section of Eclipse Galileo release
 * In eclipse preferences, in Server->Runtime Environments add your tomcat installation
 * Open Servers view and create a new server:
   * on overview tab, select 'Use Tomcat Installation (takes control of Tomcat installation)
   * click on 'open launch configuration' on overview tab
   * on 'Classpath' tab, add all runtime-dependencies and the project itself (use 'Add Projects...' button) in 'User Entries' section
   * on 'Source' tab add candlepin-proxy project
   * click 'ok' - we're done here
   * switch to 'modules' tab: add a new external module and point it to 'candlepin/code/webapp' directory

## Debugging with Tomcat
To enable remote debugging in Tomcat, you must pass the JVM values telling it to enable JDWP.

1. Open `/etc/tomcat/tomcat.conf`
1. Add the following to the `CATALINA_OPTS` variable:

   ```
   -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000
   ```
   Now you will be able to connect a debugger to port 8000.

   The `-Xdebugger -Xrunjdwp` version of enabling the debugger has been
   [deprecated as of Java 5](http://docs.oracle.com/javase/6/docs/technotes/guides/jpda/conninv.html).
   Use `-agentlib` instead.
   {:.alert-notice}


## Building RPMs with Tito
Candlepin uses Tito to build the rpms, see [here](building_rpms_with_tito.html).

## Using LogDriver (logging JDBC driver)
To use the logging JDBC driver with Candlepin see [the log driver page](logdriver.html)

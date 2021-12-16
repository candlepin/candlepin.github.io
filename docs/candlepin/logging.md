---
title: Logging in Candlepin
---
{% include toc.md %}

# Logging in Candlepin
We use [SLF4J](http://www.slf4j.org/) in Candlepin.  SLF4J is a logging facade
that can bridge to multiple logging implementations (including Log4j,
java.util.logging, and others).  We are using [Logback](http://logback.qos.ch/)
as our implementation.

## SLF4J
When possible, only have your class rely on classes from SLF4J.  Using facade
gives us flexibility.  Under most circumstances, this is all you will need to
do.

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Foo {
    private static Logger log = LoggerFactory.getLogger(Foo.class);

    public static void main(String[] args) {
        log.info("Hello world")
    }
}
```

Note that the log object is declared as static.  There is [some
debate](http://www.slf4j.org/faq.html#declared_static) about this practice, but
on Candlepin we stick to statics because our code isn't meant to be deployed on
a shared classpath.

Now let's say you want to print out an object.  That's where SLF4J shines: parameterized messages.  Here's the old way:

```java
//DO NOT DO THIS ANYMORE
Object x = new Something();
log.debug("Hello " + x);
```
{:.alert-bad}

The old way incurs the cost of the toString() operation as soon as the debug()
method is called *even if logging is not set at debug level* (whereupon the
message wouldn't be logged at all).  You can get around this with a
`if(log.isDebugEnabled())` but that gets really ugly fast.  With parameterized
messages the cost of the toString() operation is deferred until we know that we
are actually going to log the message.  Here is the new way:

```java
Object x = new Something();
log.debug("Hello {}", x);
```

What if you don't want to log any message, but just the object itself?  Easy: `log.debug("{}", x)`

If you are going to perform some expensive method call in the logging statement
and you want to avoid the cost when possible, then you *are* going to have to
use an if statement because the nested method call is going to get resolved
before debug() is called.

```java
Object x = new Something();
if (log.isDebugEnabled()) {
    log.debug("Hello {}", x.doSomethingExpensive());
}
```

That's about all you need to know about SLF4J but I recommend reading the [FAQ](http://www.slf4j.org/faq.html)

## Logback
First, read [the manual](http://logback.qos.ch/manual/introduction.html).
Specifically the chapters on architecture (which is very similar to Log4J's),
configuration, filters, and Mapped Diagnostic Contexts.  The rest you can just
refer to when you need it.

If you want to do something fancy with logging, then you are going to need to
access the underlying implementation.  SLF4J doesn't really allow you to
configure loggers.  To interact with Logback, you need to get the logging
context first.

```java
LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
```

With the context, you can access Loggers, attach new Appenders, etc.

### Logback Gotchas and Tips
* If you create something new, you're probably going to need to ```start()```
  it.  If the Logback class you're using implements LifeCycle (and the Filters,
  Appenders, Evaluators, TurboFilters, and Encoders all do), you need to set it
  up and then call `start()` otherwise it's not going to do anything.
  Loggers are the exception to this rule.
* If your logging configuration is wrong or messed up, Logback will print error
  messages to STDERR.  With Tomcat, those messages end up in catalina.out and
  **not** in candlepin.log!
* If you really want to see what's going on during set up, you can add the
  `debug="true"` attribute to the `configuration` element in
  logback.xml.  See <http://logback.qos.ch/manual/configuration.html#automaticStatusPrinting>
* Logback has really powerful filtering using Janino where you can place Java
  expressions in the filter definition and they will be evaluated at logging
  time to determine whether or not to log a statement.  *We do not use these*.
  Janino would be another dependency that we'd have to manage.  If you want to
  use Janino evaluators during testing (you'd have to add the Janino library to
  Candlepin's classpath) that's fine but don't check them in.
* TurboFilters trump log level!  If a TurboFilter accepts a log event, then it
  will get logged.  If the TurboFilter denies it, then it won't.  So be careful
  with your TurboFilters.  In some cases it may be necessary to add an
  additional Filter to an Appender to keep out events accepted by TurboFilters.
* If you are an extreme power user, you can use Logback's JMX functionality to
  alter logging configuration at run-time.  See <http://logback.qos.ch/manual/jmxConfig.html>

## Our Customizations
We have a few customizations to logging.

* Logger levels are set primarily in /etc/candlepin/candlepin.conf.

  ```properties
  log4j.logger.org.candlepin.servlet.filter=DEBUG
  ```

  The "log4j.logger" part is just a prefix; the rest is the Logger name and
  then the level you want.  The LoggingConfig class handles setting the
  Loggers.  This means that you should hardly ever actually need to touch
  logback.xml which is where the basic configuration is.
* The LoggingFilter is a servlet filter that "tees" the ServletRequest and
  ServletResponse so that we can log them.  It also adds a request UUID to the
  MDC.
* Superadmins can enable different logging levels for different orgs.  To set to debug:

  ```console
  $ curl -k -u admin:admin -X PUT "https://localhost:8443/candlepin/owners/{owner_key}/log"
  ```

  You can specify other levels with a level query param.  For example

  ```console
  $ curl -k -u admin:admin -X PUT "https://localhost:8443/candlepin/owners/{owner_key}/log?level=TRACE"
  ```

  To turn org level logging off

  ```console
  $ curl -k -u admin:admin -X DELETE "https://localhost:8443/candlepin/owners/{owner_key}/log"
  ```

* The AuthInterceptor then authenticates you and sees if you have authorization
  to make the request you made.  If you do, it will place your org key and org
  logging level in the MDC.  Keep in mind that if you fail authentication or
  authorization, we probably won't know your org or org log level because
  AuthInterceptor aborts as soon as there is a failure.
* **To mitigate this problem, if you are writing a method with multiple
  `@Verify` annotated parameters put the parameters in order of likelihood that
  the user will pass them.  That way we will have the org if a subsequent
  parameter fails its `@Verify` check.**  Most methods don't have multiple
  `@Verify` annotations so this shouldn't be a common occurrence.
* The org level logging is handled by the LoggerAndMDCFilter class which is a TurboFilter.

## Logging SQL queries and parameters

Hibernate has a great feature that will show the SQL statements which is some
what useful for debugging. To turn this on simply add set ['hibernate.show_sql
= true'](https://forum.hibernate.org/viewtopic.php?p=2401574).
This will show the SQL logging in Tomcat's catalina log. To show these in the candlepin.log,
you can set the following properties (in /etc/candlepin/candlepin.conf):

```properties
log4j.logger.org.hibernate=INFO
log4j.logger.org.hibernate.SQL=DEBUG # shows the queries
log4j.logger.org.hibernate.type.descriptor.sql=TRACE # shows query parameter values
```

### Sample output
```
2021-12-16 10:15:46,507 [thread=localhost-startStop-1] [=, org=, csid=] DEBUG org.hibernate.SQL - select asyncjobst0_.id as id1_18_, asyncjobst0_.created as created2_18_, asyncjobst0_.updated as updated3_18_, asyncjobst0_.attempts as attempts4_18_, asyncjobst0_.correlation_id as correlat5_18_, asyncjobst0_.end_time as end_time6_18_, asyncjobst0_.executor as executor7_18_, asyncjobst0_.job_group as job_grou8_18_, asyncjobst0_.job_key as job_key9_18_, asyncjobst0_.log_execution_details as log_exe10_18_, asyncjobst0_.log_level as log_lev11_18_, asyncjobst0_.max_attempts as max_att12_18_, asyncjobst0_.name as name13_18_, asyncjobst0_.origin as origin14_18_, asyncjobst0_.owner_id as owner_i15_18_, asyncjobst0_.previous_state as previou16_18_, asyncjobst0_.principal as princip17_18_, asyncjobst0_.job_result as job_res18_18_, asyncjobst0_.start_time as start_t19_18_, asyncjobst0_.state as state20_18_, asyncjobst0_.version as version21_18_ from cp_async_jobs asyncjobst0_ where (asyncjobst0_.state in (?)) and (asyncjobst0_.executor in (?))
2021-12-16 10:15:46,508 [thread=localhost-startStop-1] [=, org=, csid=] TRACE org.hibernate.type.descriptor.sql.BasicBinder - binding parameter [1] as [INTEGER] - [4]
2021-12-16 10:15:46,508 [thread=localhost-startStop-1] [=, org=, csid=] TRACE org.hibernate.type.descriptor.sql.BasicBinder - binding parameter [2] as [VARCHAR] - [candlepin.example.com]
```

## Logging to Syslog
Logging to syslog is possible but it requires customization of the `logback.xml`
file packaged with Candlepin.

1. Add a section like

   ```xml
   <appender name="SyslogAppender" class="ch.qos.logback.classic.net.SyslogAppender">
       <syslogHost>localhost</syslogHost>
       <facility>DAEMON</facility>
       <suffixPattern>[%thread] %logger %msg</suffixPattern>
   </appender>
   ```

   and add an `appender-ref` element with `ref="SyslogAppender"` under the `root` element.
   E.g.

   ```xml
   <root level="WARN">
       <appender-ref ref="CandlepinAppender" />
       <appender-ref ref="SyslogAppender" />
       <appender-ref ref="ErrorAppender" />
   </root>
   ```

1. Allow syslog to listen on port 541.  The exact steps here will depend on
   whether you are using rsyslog or syslog-ng.  For rsyslog, you'll want to
   add the lines below and restart the daemon.

   ```
   # Provides UDP syslog reception
   # for parameters see http://www.rsyslog.com/doc/imudp.html
   module(load="imudp") # needs to be done just once
   input(type="imudp" port="514")
   ```

Note that if you are using a SystemD based distribution, the messages sent to
port 514 **are not going to appear in the journal**.  If you want the messages
to go to the journal as well, you'll need to use something like rsyslog's
[`omjournal`](http://www.rsyslog.com/doc/omjournal.html).  Logback itself does
not have an appender implementation for the journal, although third-party
libraries [exist](https://github.com/gnieh/logback-journal).

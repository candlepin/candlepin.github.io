---
title: Fail Fast Mechanism
---
{% include toc.md %}

Fail Fast mechanism is a set of defensive measures that Candlepin automatically takes in event of unavailability of external service (such as Qpid Broker) or misconfiguration of such external service. Some of the main challenges that Candlepin faces when external service fails include:

* Due to failing external service, Candlepin generates high amount of errors. Then its hard to pinpoint the cause of the error from the log files.
* Internal Candlepin buffers (e.g. HornetQ queue) gets overloaded, because external service is not responsive. This may cause high disk usage
* Candlepin doesn't recover from failing Qpid Broker that has been failing for extended period of time

Fail Fast mechanism currently defends against problems with Qpid Broker. It uses feature called Suspend Mode to temporarily stop Candlepin's operations.

## Suspend Mode
Candlepin can operate in two modes: NORMAL mode and SUSPEND mode. The NORMAL corresponds to standard Candlepin operation. SUSPEND mode is a state in which Candlepin stops responding to most of the requests. When in SUSPEND mode, Candlepin will return HTTP code 503. Also, all the scheduled jobs are suspended. The only available resource is `/status` endpoint. Thus, when in SUSPEND mode, clients cannot use Candlepin. The current mode of Candlepin can be discovered using `/status` endpoint. It is recommended that this endpoint is used for polling the Candlepin mode.

The feature is enabled by default and can be controlled using config property `candlepin.suspend_mode_enabled`

### Automatic transitioning
Candlepin automatically checks the external service to see if it is responsive and transitions to/from SUSPEND/NORMAL mode. 

It does so every 10 seconds by default. This can be controlled using property `candlepin.amqp.suspend.transitioner_initial_delay` . The detailed information about the operation of the automatic transitions can be enabled by logging config `log4j.logger.org.candlepin.controller.SuspendModeTransitioner=DEBUG`. When Candlepin enters SUSPEND mode, the frequency of connectivity checks is growing. The growth is following the following formula:

```
DELAY = INITIAL_DELAY + (DELAY_GROWTH * FAILED_ATTEMPTS)
```

Where the defaults for the variables are:

```
candlepin.amqp.suspend.transitioner_delay_growth = 10
candlepin.amqp.suspend.transitioner_initial_delay = 10
candlepin.amqp.suspend.transitioner_max_delay = 300
```

The `FAILED_ATTEMPTS` is the number of failed reconnection tries to the Qpid Broker. The idea behind this functionality is that we don't want to check the connectivity too often so as not to produce massive amounts of log statements.

There is also `candlepin.amqp.suspend.transitioner_max_delay` that gives ability to put upper limit to the resulting delay (-1 means unbounded).

## Qpid Broker Failures
Qpid Broker can be in three states: 

* CONNECTED - Qpid is available and usable
* DOWN - cannot initiate connection to Qpid. Either network problem or configuration problem
* FLOW_STOPPED - connection to Qpid can be made but the `event` exchange is flow stopped (overloaded). When the flow stopped, its not possible to send more messages to the exchange (the JMS client throws exception)

### Spec Tests
There is a special spec test `qpid_spec.rb` that contains integration tests that expect running Candlepin and Qpid. 

During the test, it is usually necessary to manipulate Qpid (start, stop, create queue). `candlepin_scenarios.rb` contains class `CandlepinQpid` that helps with that. Note that the spec tests need run in our Docker images, and thus must make sure to be compatible with supervisord.

The spec tests assume existence of special queue. To create it, it is necessary to deploy Candlepin with -q switch.

### Qpid Management Framework
Qpid Management Framework is proprietary Qpid, message base, protocol. It is used to manage Qpid Broker and also to retrieve information about the broker. Candlepin uses QMF (implementation in `QpidQmf.java`) in order to figure out whether an exchange is flow stopped.

### Startup Check
At the startup of Candlepin, Qpid QMF is used to check for the connectivity to the broker. If it is not CONNECTED, then Candlepin immediately fails and stops the startup. This behavior can be controlled by property `candlepin.amqp.qmf.startup_check_enabled`

---
categories: uncategorized
title: Reliable Event Delivery
---
{% include toc.md %}

Because Gutterball uses events dispatched from Candlepin, reliable delivery of those events is extremely important for accuracy of the reports.

# How Messages Are Sent

Candlepin events are dispatched first by submitting to an embedded Hornetq server using the core API. We have a small number of listeners configured to store a reduced version of the event in our database, write to /var/log/candlepin/audit.log, and optionally publish onto the AMQP bus. Hornetq gives us essentially asynchronous sending of events (the API call can return, events are sent in the background), as well as reliable delivery of the message.

It is also worth noting that events to be dispatched are gathered up during a REST API request and only sent after successful completion, if an error is encountered in Candlepin code after some event has been sent, that message will never make it to Hornetq or the message bus.

Our Hornetq messages are marked as 'durable', as are the queues they are sent to. By default hornetq stores it's journal in /var/lib/candlepin/hornetq/.

To communicate with AMQP we use the Qpid JMS client, and thus we're basically using JMS API.

Gutterball likewise uses the JMS API to receive the messages on the other end of the bus.

# Message Delivery Error Scenarios

## Qpid Message Bus Down

In this scenario, both Candlepin and Gutterball applications are live, but the Qpid message bus goes down for some reason. Both applications will log an error when this happens, they lose their connection to qpidd but continue to operate fine. Hornetq queues up messages in the durable queues we configure and will hold onto them, and re-attempt delivery the next time the application is restarted and qpidd is up.

This behaviour should hold true for any exception thrown in an EventListener, and as such we should not ignore exceptions in these classes if it's important the event reach its destination.

#### Example Test

  1. Verify gutterball is receiving events by examining logs or database.
  1. systemctl stop qpidd
    * candlepin and gutterball will both log an error at this point, their connection to qpid has been lost and will not be re-established until tomcat is restarted.
    * Neither application will start until qpidd is back up. However, they will continue to operate fine if qpidd goes down after startup.
  1. Do anything that will trigger events, register, run spec tests, etc.
  1. Verify events are getting queued up: curl -k -u admin:admin https://localhost:8443/candlepin/admin/queues
    * This shows the hornetq queues and the messages pending delivery in each. Specifically you should see the AMQP listener is queuing up messages, the others should not.
  1. systemctl start qpidd
  1. systemctl restart tomcat
  1. Verify a flurry of events arrived in gutterball by examing logs or database.


## Gutterball Application Is Down

If gutterball is down, events sit in the qpid exchange and will be sent when gutterball returns. The [default JMS time-to-live is infinite](http://docs.oracle.com/javaee/1.4/api/javax/jms/Message.html#DEFAULT_TIME_TO_LIVE) and we do not appear to specify one specifically, so the message will remain there until gutterball returns.

#### Example Test

  1. Verify gutterball is receiving events by examining logs or database.
  1. rm -rf /var/lib/tomcat/webapps/gutterball*
  1. systemctl restart tomcat
  1. Do anything that would trigger an event, registering a new system for example.
  1. Re-deploy gutterball.
  1. Verify events made it to gutterball.


## Gutterball Encounters An Error Recieving The Message

Event processing in gutterball is divided into two phases / transactions.

In the first, we attempt to simply get the event into our database with minimal processing. We parse JSON into an event, and store it in gb_event with a status that indicates it was received, then commit the transaction. If an exception is thrown in this phase, the event remains on the qpid exchange and will be re-tried whenever gutterball rejoins the bus. Note that this has been known to trigger the dreaded qpidd capacity exceeded error discussed below. However, errors here should be exceedingly rare. (no known situations can cause one)

In the second phase, we perform actual gutterball event processing. In this phase any exception should be caught and logged. Because we assigned the event an initial status of received, we know that any event remaining in the database in this state probably failed processing. (ignoring race condition for an event that is *currently* being processed) This phase has been known to fail due to bugs in the code, and on application upgrade, or perhaps on demand via an API call, gutterball could scan for such events and re-try.

### Example Test

Really no options here other than to go to gutterball and insert explicit throw exception statements.

#### Qpidd Capacity Exceeded

A potential remaining problem is if the number of messages failing to import exceeds the amount qpidd is configured to store, which results in an exception: Enqueue capacity threshold exceeded. This exception seems to only surface in high volume scenarios (parallel spec tests) when events throw an exception when being received by gutterball. Because this is only possible in phase 1 now, and we do not know of any situations where this is possible, we are hopeful the two phase approach to message processing in gutterball will prevent this.


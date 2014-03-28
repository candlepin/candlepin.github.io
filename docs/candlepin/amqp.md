---
layout: default
title: AMQP
---
{% include toc.md %}

# How to run candlepin with amqp/qpid event publication

This should get a qpid server running on your machine, and candlepin publishing messages to it over SSL.

In /etc/candlepin/candlepin.conf add:

```properties
candlepin.amqp.enable = true
```

Install qpid, generate ssl keys, and start the qpid server:

```console
$ buildconf/scripts/qpid/configure-qpid.sh
```

Restart tomcat:

```console
$ sudo service tomcat6 restart
```

## Verify its working

Here's the old method that worked without SSL:

* Install python-qpid >= 0.7 (you can get it from pulp's yum repo)
* Download <https://svn.apache.org/repos/asf/qpid/trunk/qpid/python/examples/api/drain>
* Run

  ```python
  python drain -f "event/"
  ```
* Run some of candlepin's functional tests, and watch the messages fly!

With SSL, the best I've found is to use the Java client example, which needs a full checkout of qpid:

* Checkout code.

  ```console
  $ svn checkout https://svn.apache.org/repos/asf/qpid/trunk/qpid/
  ```
* Go into the source directory.

  ```console
  $ cd qpid/java/client/examples/src/main/java
  ```
* Invoke the included script.

  ```console
  $ QPID_HOME=~/.m2/repository ./runSample.sh org.apache.qpid.example.Drain -b guest:guest@localhost:5671 --broker-option='ssl=true,ssl_cert_alias=amqp-client' -f "event/"
  ```
* Run some of candlepin's functional tests, and watch the messages fly!

## Draft Additions
[qpid connection format](https://cwiki.apache.org/qpid/connection-url-format.html)

## Notes
* install `qpid-tools`
  * add events queue `qpid-config add queue events`

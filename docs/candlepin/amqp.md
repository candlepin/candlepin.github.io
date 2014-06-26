---
title: AMQP
---
{% include toc.md %}

# How to run candlepin with amqp/qpid event publication

There are a number of ways to run Candlepin with
[Qpid](http://qpid.apache.org/index.html).
One is to install the [Qpid](http://qpid.apache.org/releases/qpid-0.26/cpp-broker/book/index.html) server and configure it alone. The more common usage
is to install [Pulp](http://www.pulpproject.org/) server or [Katello](http://www.katello.org/) and piggy back on the Qpid broker used by
those projects.

## Running Candlepin with Pulp
* Install Pulp <https://pulp-user-guide.readthedocs.org/en/pulp-2.3/installation.html>
* Install the Qpid packages

  ```console
  $ sudo yum install qpid-tools qpid-cpp-server-store
  ```

* Add an events queue

  ```console
  $ qpid-config add exchange topic events --durable
  ```
  If you are connecting to Qpid over SSL, the command will look something like

  ```console
  $ qpid-config --ssl-certificate /path/to/client_cert --ssl-key /path/to/client_key -b amqps://localhost:5671 add exchange topic events --durable
  ```
* Configure candlepin

  In /etc/candlepin/candlepin.conf add:

  ```properties
  candlepin.amqp.enable = true
  # Defaults to "tcp://localhost:5672?ssl='true'&ssl_cert_alias='amqp-client'"
  # Here I installed pulp on a machine: 192.168.1.187 with SSL
  candlepin.amqp.connect=tcp://192.168.1.187:5671?ssl='true'&ssl_cert_alias='amqp-client'
  ```

  If you are not using SSL then simply use ```tcp://IP_ADDR```

* Restart tomcat:

  ```console
  $ sudo service tomcat6 restart
  ```
* Hook up a client (like Qpid's [Python drain](http://qpid.apache.org/releases/qpid-0.26/messaging-api/python/examples/drain.html) or [Java drain](http://qpid.apache.org/releases/qpid-0.24/qpid-jms/examples/Drain.java.html)).

## Running with stand-alone Qpid server
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

Here's the old method that worked **without** SSL:

* Install python-qpid >= 0.7 (you can get it from pulp's yum repo)
* Download <https://svn.apache.org/repos/asf/qpid/trunk/qpid/python/examples/api/drain>
* Run

  ```python
  python drain -f "events/"
  ```
* Run some of candlepin's functional tests, and watch the messages fly!

With SSL, the best I've found is to use the Java client example, which needs a full checkout of qpid:

* Checkout code.

  ```console
  $ git clone https://github.com/apache/qpid.git
  ```
* Go into the source directory and build the java source.

  ```console
  $ cd qpid/qpid/java
  $ ant build
  ```
* Run the Java Drain client

  ```console
  $ java -classpath `build-classpath-directory .` -Djavax.net.ssl.trustStore=/etc/candlepin/certs/amqp/truststore -Djavax.net.ssl.keyStore=/etc/candlepin/certs/amqp/keystore -Djavax.net.ssl.keyStorePassword=password -Djavax.net.ssl.trustStorePassword=password org.apache.qpid.example.Drain --broker=guest:guest@10.13.137.187:5671 --broker-option=ssl=true,ssl_cert_alias=amqp-client -f "events/"
  ```
* Create an org and watch for incoming messages.

  ```console
  $ cd client/ruby
  $ ./cpc create_owner orgA
  ```

# Configure SSL
If you are running Pulp/Qpid on the same machine as your Candlepin server, you
can use the buildconf/scripts/qpid/setup.sh script to create a signed client
certificate.

If Pulp/Qpid is on a separate machine, you will need to sign the client
certificate on **that** machine. Copy the resulting certificate back to the
client.

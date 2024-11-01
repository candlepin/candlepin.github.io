---
title: AMQP
---
{% include toc.md %}

# Dispatching Candlepin Events With AMQP/Qpid

Below are a couple ways to configure Candlepin to dispatch events onto a [Qpid](http://qpid.apache.org/index.html) message bus.

## Standalone Qpid Server

Useful for developer or standalone deployments. The steps below will install qpid and configure candlepin to begin sending messages to it with SSL enabled.

 * Install qpid, generate ssl keys, and start the qpid server:

   ```console
   $ server/bin/qpid/configure-qpid.sh
   ```

 * Ensure candlepin is configured to connect to Qpid.

  Either generate `candlepin.conf` with Qpid enabled by passing `-q` to `server/bin/deploy` or
  in `/etc/candlepin/candlepin.conf`, manually set:

   ```properties
   candlepin.amqp.enable = true
   candlepin.amqp.connect=tcp://localhost:5671?ssl='true'&ssl_cert_alias='candlepin'
   ```

 * Restart tomcat:

   ```console
   $ sudo service tomcat restart
   ```

## Running Candlepin with Pulp

In [Katello](http://www.katello.org/) and Satellite deployments Candlepin is configured automatically to connect to the message bus set up by [Pulp](http://www.pulpproject.org/). This is normally handled automatically by the installer, but some notes on the steps involved for Candlepin are below:

* Install Pulp <https://pulp-user-guide.readthedocs.org/en/pulp-2.3/installation.html>
* Install the Qpid packages

  ```console
  $ sudo yum install qpid-tools qpid-cpp-server-store
  ```

* Add an events queue

  ```console
  $ qpid-config add exchange topic event --durable
  ```
  If you are connecting to Qpid over SSL, the command will look something like

  ```console
  $ qpid-config --ssl-certificate /path/to/client_cert --ssl-key /path/to/client_key -b amqps://localhost:5671 add exchange topic event --durable
  ```
* Configure candlepin

  In /etc/candlepin/candlepin.conf add:

  ```properties
  candlepin.amqp.enable = true
  # Defaults to "tcp://localhost:5672?ssl='true'&ssl_cert_alias='amqp'"
  # Here I installed pulp on a machine: 192.168.1.187 with SSL
  candlepin.amqp.connect=tcp://192.168.1.187:5671?ssl='true'&ssl_cert_alias='amqp'
  ```

  The SSL cert alias must match whatever is in your /etc/candlepin/certs/amqp/candlepin.jks keystore. Use 'portecle' GUI tool to examine it. (default password is 'password' in developer deployments)

  If you are not using SSL then simply use ```tcp://IP_ADDR```

* Restart tomcat:

  ```console
  $ sudo service tomcat6 restart
  ```
* Use our client in `server/bin/qpid_watch.py` to monitor and/or drain events. Alternatively, you can use Qpid's [Python drain](https://qpid.apache.org/releases/qpid-python-1.37.0/messaging-api/examples/drain) or [Java drain](https://qpid.apache.org/releases/qpid-java-6.0.2/qpid-jms/examples/Drain.java).

## Verify it's working

Here's the old method that worked **without** SSL:

* Install python-qpid >= 0.7 (you can get it from pulp's yum repo)
* Download <https://qpid.apache.org/releases/qpid-python-1.37.0/messaging-api/examples/drain>
* Run

  ```python
  python drain -f "event/"
  ```
* Run some of candlepin's functional tests, and watch the messages fly!

With SSL, the most convenient way to monitor and/or drain events is to use our own client found in `server/bin/qpid_watch.py`:

```console
$ cd server/
$ bin/qpid_watch.py -c bin/qpid/keys/qpid_ca.crt -k bin/qpid/keys/qpid_ca.key -s event --timeout -1 --show-message --drain
```

Alternatively, you could use the Java client example, which needs a full checkout of qpid:

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
  $ cd build/lib
  $ java -classpath `build-classpath-directory .` -Djavax.net.ssl.trustStore=/etc/candlepin/certs/amqp/candlepin.truststore -Djavax.net.ssl.keyStore=/etc/candlepin/certs/amqp/candlepin.jks -Djavax.net.ssl.keyStorePassword=password -Djavax.net.ssl.trustStorePassword=password org.apache.qpid.example.Drain --broker=guest:guest@localhost:5671 --broker-option=ssl=true,ssl_cert_alias=amqp -f "event/"
  ```
* Create an org and watch for incoming messages.

  ```console
  $ cd server/client/ruby
  $ ./cpc create_owner orgA
  ```

Another option is to use `qpid-printevents` although it does not let you
confine the output to a specific exchange.

```console
$ qpid-printevents --ssl-certificate foo.cert --ssl-key foo.key amqps://localhost:5671
```

## List of useful Qpid cli commands

If you have set up a standalone qpid server, the ssl certificate can be found in `server/bin/qpid/keys/candlepin.crt`, and the ssl key in `server/bin/qpid/keys/candlepin.key`.

* Get message counts and general stats.

  ```console
  $ sudo qpid-stat --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 -q allmsg
  ```

* List the bindings (routes) for a queue.

  ```console
  $ sudo qpid-config --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 queues allmsg -r
  ```

* List the current exchanges.

  ```console
  $ sudo qpid-config --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 exchanges
  ```

* Delete An Exchange.

  ```console
  $ sudo qpid-config --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 del exchange event
  ```

* Create an exchange.

  ```console
  $ sudo qpid-config --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 add exchange topic event --durable
  ```

* Create a binding for the exchange.

  ```console
  $ sudo qpid-config --ssl-certificate=path/to/cert --ssl-key path/to/key -b amqps://localhost:5671 bind event allmsg '#'
  ```


# Configure SSL
If you are running Pulp/Qpid on the same machine as your Candlepin server, you
can use the configure-qpid.sh script to create a signed client
certificate.

If Pulp/Qpid is on a separate machine, you will need to sign the client
certificate on **that** machine. Copy the resulting certificate back to the
client.

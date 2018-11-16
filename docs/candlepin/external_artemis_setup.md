---
title: Configuring A Remote Artemis Server 
---
{% include toc.md %}

# Configuring A Remote Artemis Server
By default, candlepin runs with an embedded Artemis server. Candlepin does however support running against a remote Artemis server. The following guide will walk you through installing a remote Artemis server with basic configuration. Because candlepin relys on very specific queues and addresses, it is not advised to mess with these configuration settings.

## Installing Artemis
First, stop tomcat so that the embedded Artemis instance is shut down to avoid port conflicts.

```bash
sudo systemctl stop tomcat
```

Run the following to install Artemis and to create an instance of a broker.
```bash
cd /opt
sudo wget https://archive.apache.org/dist/activemq/activemq-artemis/2.4.0/apache-artemis-2.4.0-bin.tar.gz
sudo tar xvzf apache-artemis-2.4.0-bin.tar.gz
sudo rm apache-artemis-2.4.0-bin.tar.gz
sudo mkdir /var/lib/artemis
cd /opt/apache-artemis-2.4.0
sudo bin/artemis create --user admin --password admin --allow-anonymous /var/lib/artemis/candlepin
```

## Setup Artemis As A Service

Create a service file for Artemis: /usr/lib/systemd/system/artemis.service
```
[Unit]
Description=Apache ActiveMQ Artemis
Requires=network.target
After=network.target

[Service]
User=artemis
Group=artemis
PIDFile=/var/lib/artemis/candlepin/data/artemis.pid
ExecStart=/var/lib/artemis/candlepin/bin/artemis-service start
ExecStop=/var/lib/artemis/candlepin/bin/artemis-service stop
ExecReload=/var/lib/artemis/candlepin/bin/artemis-service restart
Restart=always

[Install]
WantedBy=mult-user.target
```

Create a user and group for artemis.
```
sudo useradd artemis --home /var/lib/artemis
sudo chown -R artemis:artemis /var/lib/artemis
```

Setup an SELinux policy for the artemis service. In a temp directory, create an ***artemisservice.te*** file contining the following.
```bash
module artemisservice 1.0;

require {
    type var_lib_t;
    type init_t;
    class file { execute execute_no_trans };
}

#============= init_t ==============
allow init_t var_lib_t:file { execute execute_no_trans };
```

Compile and load the policy.
```bash
checkmodule -M -m -o artemisservice.mod artemisservice.te
semodule_package -m artemisservice.mod -o artemisservice.pp

# Remove the existing module if it exists.
sudo semodule -vr artemisservice

# Reload the artemisservice module
sudo semodule -vi artemisservice.pp
```

## Configure Artemis and Candlepin Connections
Configure Artemis using the default broker.xml that is packaged in the candlepin war file.

***Note:*** The default Artemis config file contains some useful information and settings as the Artemis installation adds some performance tuning settings for the installation.

```bash
cd /var/lib/artemis/candlepin
sudo mv etc/broker.xml etc/broker.old
sudo cp /var/lib/tomcat/webapps/candlepin/WEB-INF/classes/broker.xml etc/
```

Edit the etc/broker.xml file to configure the appropriate acceptor.
```xml
        <acceptors>
            <acceptor name="netty">tcp://localhost:61617</acceptor>
        </acceptors>
```
Edit the /etc/candlepin/candlepin.conf as follows:
```bash
candlepin.audit.hornetq.embedded=false
candlepin.audit.hornetq.broker_url=tcp://localhost:61617
```

Start the artemis service and ensure that there were no errors.
```
sudo systemctl start artemis
sudo systemctl status artemis
```

In a seperate terminal, tail and grep the logs to make sure that candlepin is running against the remote Artemis server when it starts.

```bash
tail -f /var/log/candlepin/candlepin.log  | grep "Candlepin will connect"
```

Restart candlepin. Once candlepin starts, you should see a log entry from above that reads:

***INFO  org.candlepin.audit.ActiveMQContextListener - Candlepin will connect to a remote Artemis server.***

```bash
sudo systemctl restart tomcat
```

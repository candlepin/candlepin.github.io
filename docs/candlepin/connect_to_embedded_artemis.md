---
title: Allow Remote Connections to embedded Artemis 
---
{% include toc.md %}

# Allow Remote Connections to embedded Artemis


Following changes need to be done in broker.xml.

First thing we need is to add an [acceptor](https://activemq.apache.org/components/artemis/documentation/1.0.0/configuring-transports.html) for the IP address the client will be calling.
```xml
<acceptor name="netty">tcp://192.168.121.77:61617</acceptor>
```

Next we define an address the client will be connecting to. We don't need to define a queue as they will be created automatically for the connected clients.

```xml
<address name="event.artemis">
    <multicast/>
</address>
```

Settings for the address.
```xml
<address-setting match="event.artemis">
    <auto-create-queues>true</auto-create-queues>
    <max-size-bytes>10485760</max-size-bytes>
    <page-size-bytes>1048576</page-size-bytes>
    <redelivery-delay>30000</redelivery-delay>
    <max-redelivery-delay>3600000</max-redelivery-delay>
    <redelivery-delay-multiplier>2</redelivery-delay-multiplier>
    <max-delivery-attempts>0</max-delivery-attempts>
</address-setting>
```

Last change is to divert the messages from default queue to the artemis queue. This will copy all messages coming to **event.default** and send them to the **event.artemis**.
```xml
<divert name="artemis_divert">
    <exclusive>false</exclusive>
    <address>event.default</address>
    <forwarding-address>event.artemis</forwarding-address>
</divert>
```


After restart of Candlepin any client can connect and listen to the messages in the **event.artemis** queue.

# SSL
In Artemis, Netty is responsible for all things related to the transport layer, so it handles [SSL](https://activemq.apache.org/components/artemis/migration-documentation/ssl.html) as well. All configuration options are set directly on the acceptor.
```xml
<acceptor name="netty-ssl">tcp://localhost:61617?sslEnabled=true;keyStorePath=${data.dir}/../etc/broker.ks;keyStorePassword=password;needClientAuth=true</acceptor>
```

# External broker.xml
By default Candlepin uses broker.xml packaged with it. Candlepin can be set to use external broker.xml by setting its path in Candlepin property **candlepin.audit.hornetq.config_path**.
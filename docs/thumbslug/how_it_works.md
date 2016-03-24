---
title: How Thumbslug Works
---
{% include toc.md %}

## Overview

In a hosted scenario, the user's system gets a certificate (1) and then is able to access the CDN (2).

```text
-------------------      (             )
|    Hosted CP    |     (    C D N      )
-------------------      (_  __  __  __)
         \              /
     1.   \           /   2.
           \        /
          -------------
          |  system   |
          -------------
```

However, in the on-premise scenario, the user's system isn't able to access the CDN (see broken line at 3), since their cert was cut from the on-premise CP (2) and not the hosted CP (1).

```text
-------------------      (             )
|    Hosted CP    |     (    C D N      )
-------------------      (_  __  __  __)
         \                    |
     1.   \                   |
           \                  |
      ---------------------    
      |  On-premise CP    |   T  3.
      ---------------------   |
                |           _/
                |         _/
            2.  |       _/
                |      /  
              -------------
              |  System   |
              -------------
```

Enter thumbslug. It takes the network call from step 3, and makes a call to the
on-premise candlepin (4) to get the certificate used during the initial
on-premise setup that was cut from hosted CP in step 1. It then uses that to
make the call to the CDN (5), and relays the data back to the user's system.
Note that only steps 3, 4, and 5 are done at file fetch time, steps 1 and 2 are
simply setup steps that occur once during CP import and system registration
respectively.

```text
-------------------      (             )
|    Hosted CP    |     (    C D N      )
-------------------      (_  __  __  __)
         \                    |
     1.   \                   | 5.
           \                  |
 --------------------  4.   ---------------
 |  On-premise CP   |<----> | Thumbslug   |
 --------------------       ---------------
                |           _/
                |         _/    
            2.  |       _/  3.
                |      /  
              -------------
              |  System   |
              -------------
```

Here is the same scenario, but with a corporate firewall (6):

```text
 -------------------      (             )
 |    Hosted CP    |     (    C D N      )
 -------------------      (_  __  __  __)
           |                   |
           |                   | 6.         
      1.   |            .------|-----------. 
           |           /  -------------     \ 
           |          /   |   https   |      |
           |         /    |  connect  |      |
           |        /     |   proxy   |      |
           |       /      -------------      | 
 .---------|-------            |             |
/          |                   | 5.          |
|          |                   |             |
| --------------------  4.   --------------- |
| |  On-premise CP   |<----> | Thumbslug   | |
| --------------------       --------------- |
|                |           _/              |
|                |         _/                |
|            2.  |       _/  3.              |
|                |      /                    |
|              -------------                 |
|              |  System   |                 |
|              -------------                 |
.                                            .
 \__________________________________________/ 
```

## Developer Notes
Thumbslug uses [Netty](http://netty.io/) to perform its IO.
[Netty](http://netty.io/) is controlled via a series of pipelines that are set
up, and network traffic flows through. This can be hard to visualize since it's
non-procedural. Once you understand it though, it is pretty cool!

Initialization from Main:

```java
// Set up the event pipeline factory.
bootstrap.setPipelineFactory(new HttpServerPipelineFactory(config));

// Bind and start to accept incoming connections.
Channel channel = bootstrap.bind(new InetSocketAddress(port));
```

One of the key features of Netty is the pipeline architecture. The
[ChannelPipeline](http://docs.jboss.org/netty/3.2/api/org/jboss/netty/channel/ChannelPipeline.html)
javadoc offers a great introduction into why we perform the following steps in
the HttpServerPipelineFactory.

As you can see,
[HttpServerPipelineFactory](https://github.com/candlepin/thumbslug/blob/master/src/main/java/org/candlepin/thumbslug/HttpServerPipelineFactory.java)
does more detailed setup:

```java
pipeline.addLast("decoder", new HttpRequestDecoder());

pipeline.addLast("encoder", new HttpResponseEncoder());
       
pipeline.addLast("logger", new HttpRequestLogger(config.getProperty("log.access")));

pipeline.addLast("handler", new HttpRequestHandler(config, channelFactory, httpClientPipelineFactory));
return pipeline;
```

Of course, this doesn't do SSL decryption. Here is a snippet of code from
before we set up the above pipes. _Note that we have setUseClientMode set to
false here, we are acting as a *server* on this side of the pipeline_:

```java
if (config.getBoolean("ssl")) {
    SSLEngine engine =
        SslContextFactory.getServerContext(
            config.getProperty("ssl.keystore"),
            config.getProperty("ssl.keystore.password")).createSSLEngine();
    engine.setUseClientMode(false);
    engine.setNeedClientAuth(true);
    pipeline.addLast("ssl", new SslHandler(engine));
}
```

Now, the last step of the pipeline creation snippet (the one that uses the
[HttpRequestHandler](https://github.com/candlepin/thumbslug/blob/master/src/main/java/org/candlepin/thumbslug/HttpRequestHandler.java)
ctor) builds up a handler that sends data on to the CDN. This is actually a few
steps, since we need to re-encrypt before sending the data upstream. _Note that
here, we are acting as a *client* to the cdn_:

```java
if (useSSL) {
    SSLEngine engine = SslContextFactory.getClientContext(
        config.getProperty("ssl.client.keystore"),
        config.getProperty("ssl.client.keystore.password")).createSSLEngine();
    engine.setUseClientMode(true);
    pipeline.addLast("ssl", new SslHandler(engine));
}

pipeline.addLast("codec", new HttpClientCodec());

pipeline.addLast("handler", new HttpRelayingResponseHandler(client, keepAlive));
return pipeline;
```

I left out some important steps regarding connection set up and teardown, but
the general idea of how thumbslug uses netty is what's explained above.

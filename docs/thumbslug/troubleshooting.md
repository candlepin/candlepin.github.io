---
layout: default
categories: thumbslug
title: Troubleshooting
---
{% include toc.md %}

# `bad_certificate`
```console
Jul 17 15:13:46 [pool-2-thread-4] ERROR org.candlepin.thumbslug.HttpRequestHandler - Exception caught!
javax.net.ssl.SSLException: Received fatal alert: bad_certificate
	at sun.security.ssl.Alerts.getSSLException(Alerts.java:208)
	at sun.security.ssl.SSLEngineImpl.fatal(SSLEngineImpl.java:1630)
	at sun.security.ssl.SSLEngineImpl.fatal(SSLEngineImpl.java:1598)
	at sun.security.ssl.SSLEngineImpl.recvAlert(SSLEngineImpl.java:1767)
	at sun.security.ssl.SSLEngineImpl.readRecord(SSLEngineImpl.java:1063)
	at sun.security.ssl.SSLEngineImpl.readNetRecord(SSLEngineImpl.java:887)
	at sun.security.ssl.SSLEngineImpl.unwrap(SSLEngineImpl.java:761)
	at javax.net.ssl.SSLEngine.unwrap(SSLEngine.java:624)
	at org.jboss.netty.handler.ssl.SslHandler.unwrap(SslHandler.java:895)
	at org.jboss.netty.handler.ssl.SslHandler.decode(SslHandler.java:620)
	at org.jboss.netty.handler.codec.frame.FrameDecoder.callDecode(FrameDecoder.java:282)
	at org.jboss.netty.handler.codec.frame.FrameDecoder.messageReceived(FrameDecoder.java:216)
	at org.jboss.netty.channel.Channels.fireMessageReceived(Channels.java:274)
	at org.jboss.netty.channel.Channels.fireMessageReceived(Channels.java:261)
	at org.jboss.netty.channel.socket.nio.NioWorker.read(NioWorker.java:351)
	at org.jboss.netty.channel.socket.nio.NioWorker.processSelectedKeys(NioWorker.java:282)
	at org.jboss.netty.channel.socket.nio.NioWorker.run(NioWorker.java:202)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:615)
	at java.lang.Thread.run(Thread.java:724)
```

## Solution
This means just that, you have a BAD certificate. In other words, one of the
certificates either the one being presented or the one in the keystore is not
correct. In my particular case I did not have the 'candlepin-ca.crt' in my
thumbslug keystore. I followed the instructions from the thumbslug README which
was just an *example* command not an actual command. To solve this I copied the
keystore from candlepin to `/etc/thumbslug/server_keystore.p12` and restarted
thumbslug.

# `empty text`
```console
Jul 18 12:31:17 [pool-2-thread-3] ERROR org.candlepin.thumbslug.HttpRequestHandler - Exception caught!
java.lang.IllegalArgumentException: empty text
	at org.jboss.netty.handler.codec.http.HttpVersion.<init>(HttpVersion.java:103)
	at org.jboss.netty.handler.codec.http.HttpVersion.valueOf(HttpVersion.java:68)
	at org.jboss.netty.handler.codec.http.HttpRequestDecoder.createMessage(HttpRequestDecoder.java:81)
	at org.jboss.netty.handler.codec.http.HttpMessageDecoder.decode(HttpMessageDecoder.java:198)
	at org.jboss.netty.handler.codec.http.HttpMessageDecoder.decode(HttpMessageDecoder.java:107)
	at org.jboss.netty.handler.codec.replay.ReplayingDecoder.callDecode(ReplayingDecoder.java:470)
	at org.jboss.netty.handler.codec.replay.ReplayingDecoder.messageReceived(ReplayingDecoder.java:443)
	at org.jboss.netty.channel.Channels.fireMessageReceived(Channels.java:274)
	at org.jboss.netty.channel.Channels.fireMessageReceived(Channels.java:261)
	at org.jboss.netty.channel.socket.nio.NioWorker.read(NioWorker.java:351)
	at org.jboss.netty.channel.socket.nio.NioWorker.processSelectedKeys(NioWorker.java:282)
	at org.jboss.netty.channel.socket.nio.NioWorker.run(NioWorker.java:202)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:615)
	at java.lang.Thread.run(Thread.java:724)                                      
```

## Solution
Ensure `ssl=true` is set in your `/etc/thumbslug/thumbslug.conf`

# Peer Cert Cannot Be Verified
If yum reports the following:

```console
$ yum install zsh
Loaded plugins: product-id, refresh-packagekit, security, subscription-manager
This system is receiving updates from Red Hat Subscription Management.
https://transam.rdu.redhat.com:8088/foo/path/always/6Server/repodata/repomd.xml: [Errno 14
] Peer cert cannot be verified or peer cert invalid
Trying other mirror.
Error: Cannot retrieve repository metadata (repomd.xml) for repository: always-enabled-content.
Please verify its path and try again
```

## Solution
For the most part this error is what you see when thumbslug throws
[bad_certficate](#badcertificate) or [empty_text](#empty-text). But if you
still get this error after resolving those 2 situations, the likely candidate
will be a bad CA cert.  Ensure you have the correct certs in `/etc/rhsm/ca`.

# Can't Connect to Host
If for some reason yum can't connect to your machine and you swear you updated
your firewall, **check it again**, especially if you are using
[firewalld](https://fedoraproject.org/wiki/FirewallD#Working_with_firewalld).

## Solution
```console
$ sudo firewall-cmd --permanent --zone=work --add-port=8088/tcp
```

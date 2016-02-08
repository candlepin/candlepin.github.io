---
categories: developers
title: Debugging SSL/TLS with Wireshark
---
# Debugging SSL/TLS with Wireshark
Sometimes I want to see what Candlepin is really doing, so I use Wireshark to
sniff the packets.  With just the default settings, this isn't too useful
because everything is encrypted; however, Wireshark can dissect SSL and show
you the HTTP underneath.

WARNING: Decrypting SSL/TLS traffic that is using a cipher suite with
Diffie-Hellman Ephemeral key exchange will not work.[^1]  If your decryption
isn't working, go to the ServerHello section of the traffic and look at the
Cipher Suite.  If it has the string `DHE` in it, you're using Diffie-Hellman
Ephemeral.  You need to either change the cipher suites supported by the
server (the `SSLCipherSuite` directive in Apache[^2] and controlled in the
`Connector` element in Tomcat's `server.xml`) or set the client to not tell
the server that it supports any DHE suites.
{:.alert-bad .output-only}

Here's how:

1. Install wireshark and add yourself to the wireshark group so you don't have to run it as root all the time.

   ```
   $ sudo yum install wireshark-gnome
   $ sudo usermod -a -G wireshark `whoami`
   ```

   Log in to the new group (so you don't have to log out and back in again).

   ```
   $ newgrp wireshark
   ```

   Make sure you're in the group.

   ```
   $ groups
   ... wireshark ...
   ```

1. Run Wireshark.
1. Go to Edit -> Preferences.  Click Protocols.  Go to SSL.  Enter a value for
   SSL debug file.[^3]  (I use /tmp/ssl.debug).  Click RSA keys list.
   Click new and add the following entry for your localhost:

   ```
   IP address: 127.0.0.1
   Port: 8443
   Protocol: http
   Key File: /etc/candlepin/certs/candlepin-ca.key
   ```

    Now add another entry for your externally facing IP.  (Run ifconfig em1 if you don't know it)

   ```
   IP address: YOUR_IP_HERE
   Port: 8443
   Protocol: http
   Key File: /etc/candlepin/certs/candlepin-ca.key
   ```

1. Go to Capture -> Options.  Select the interface you want to listen on.  This
   step is very important and it took me a long time to figure this out.  Do
   not listen on the pseudo-interface "any".  If you listen to "any" and you're
   connecting to Candlepin from a local virtual machine, you'll get a bunch of
   TCP retransmissions.  These packets will break the SSL dissector.[^4] [^5]
   Instead check the box for the appropriate interface. "em1"
   if you're getting packets from another machine, "virbr0" if the packets are
   coming from a local VM, and "lo" if the packets are coming from localhost.
   (You can check all three of these options if you want and Wireshark will
   listen to all three interfaces.  I haven't seen the retransmission problem
   when doing this.)
1. Double click on interface to add a filter.  In the Capture Filter box enter
   "port 8443" to filter calls to those hitting the Candlepin default port.
   Filters are very powerful and you can do a lot of fancy stuff with them.
   Learn more at http://wiki.wireshark.org/CaptureFilters
1. Exit the interface settings by clicking OK and then click Start on the
   Capture Options dialog.
1. You are now sniffing packets
1. Make a request to Candlepin and you'll start seeing packets populate the
   window.  You can enter "http" in the Filter box if you just want to see the
   HTTP requests or "ssl" if you want to see the SSL stuff too.

#### Footnotes
[^1]: <https://ask.wireshark.org/questions/7886/ssl-decrypting-problem>
[^2]: <http://httpd.apache.org/docs/2.2/mod/mod_ssl.html#sslciphersuite>
[^3]: Used to be required because of <https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=6033> but now it's just good practice.
[^4]: <http://www.wireshark.org/lists/wireshark-dev/200805/msg00067.html>
[^5]: <http://www.wireshark.org/lists/wireshark-dev/201202/msg00071.html>

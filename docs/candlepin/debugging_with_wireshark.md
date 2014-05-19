---
categories: developers
title: Debugging SSL with Wireshark
---
# Debugging SSL with Wireshark
Sometimes I want to see what Candlepin is really doing, so I use Wireshark to
sniff the packets.  With just the default settings, this isn't too useful
because everything is encrypted; however, Wireshark can dissect SSL and show
you the HTTP underneath.

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
   SSL debug file.[^1]  (I use /tmp/ssl.debug).  Click RSA keys list.
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
   TCP retransmissions.  These packets will break the SSL dissector.[^2] [^3]
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
[^1]: Used to be required because of <https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=6033> but now it's just good practice.
[^2]: <http://www.wireshark.org/lists/wireshark-dev/200805/msg00067.html>
[^3]: <http://www.wireshark.org/lists/wireshark-dev/201202/msg00071.html>

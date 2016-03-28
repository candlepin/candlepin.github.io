---
title: Supporting Multiple Servlet Containers
---
{% include toc.md %}

# Using a New Servlet Container

## Current Situation
The Candlepin developer deploy scripts are fairly reliant on only being
deployed in Apache Tomcat.  Up to this point, this has been a reasonable
assumption, but this page outlines necessary steps to deploy Candlepin in other
servlet containers, notably [Jetty](http://jetty.codehaus.org/jetty/).

## Approaches
There are several ways that we can make use of Jetty to run Candlepin:

1. Install the Jetty rpm, deploy the Candlepin war to /var/lib/jetty/webapps:
   This is essentially replacing Tomcat with Jetty, but treating the container
   in the same fashion.  We would need to own the entire container, and make
   modifications to the global jetty.xml file to configure SSL, etc.  No real
   advantages over Tomcat.
1. Modify the init.d scripts that ship with the Jetty rpm to use a custom
   jetty.xml (called candlepin-jetty.xml or something) that holds our container
   configuration, including custom ports if that is desired.  This has the
   benefit of using Jetty, but making a candlepind service that is independent
   of any system-wide servlet container.  I like this approach the best, as we
   keep any changes (regarding SSL or anything else) isolated to our project.
1. I was playing around with embedding Jetty, but since Candlepin is really a
   war to be deployed in a container, there is really nothing to embed it in.
   In my view there is not much to gain by this approach that you couldn't do
   with the second option above.

## Deploy Script Changes
We should hang on to our Tomcat work, as I would think that this is a likely
deployment scenario, so these changes are likely driven off of a config option
in the deploy script.

* Modify service call to use our init.d script (or Jetty's) instead of Tomcat
* Modify file permissions for hornetq and /var/{lib,log,cache}/candlepin
* Modify the SSL keystore using the java keytool - I had to run this to make Jetty happy:

  ```
  keytool -importkeystore -srckeystore /etc/candlepin/certs/keystore -srcstoretype PKCS12 -destkeystore /etc/candlepin/certs/java-keystore
  ```

## Packaging/Deployment
One idea for packaging would be to package the war file as candlepin-core.rpm
(or something similar), then have container specific rpms for configuring
candlepin in that container - defaulting the standard candlepin.rpm to use our
Jetty version (where a user could alternatively install candlepin-tomcat.rpm if
that is desired).

## Advantages
The biggest advantage that I see is isolating any configuration to run
Candlepin to our own configuration file, and not impacting other projects.
This also fits more into the RHEL/Fedora convention and would likely help with
integration across other services.  I was not able to do any meaningful
performance testing between Jetty and Tomcat, but my suspicion is that the
servlet container will not play a significant role in the overall performance
compared to the application, database, etc.  If we choose to pursue this option
further, it would be beneficial to verify that suspicion with real benchmarks.

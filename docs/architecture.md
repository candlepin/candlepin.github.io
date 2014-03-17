---
layout: default
title: Architecture
---
{% include toc.md %}

# Architecture
Candlepin is a Java web application which exposes a REST API. It can be
deployed inside of any web container. Services are injected using the
[guice](http://code.google.com/p/google-guice/) IoC engine. Persistence is done
via hibernate.

To enable the REST API, each resource (or namespace) is backed by a
corresponding Resource class. For example, the `/owner/` urls are all handled
by the OwnerResource class.

## Technology
This page attempts to describe the thought process behind the public API for
both the Entitlement Proxy and Entitlement Service.

## Protocols

 * REST/JSON
  * REST traditionally uses the 4 HTTP verbs: GET, POST, PUT, DELETE. The urls
    are typically nouns. For example if you want to create a new organization
    the call might look something like
    http://...example.com/api/rest/organization?orgname=Fee%20Fi (via a POST).
    To load org 10 it might look as follows:
    http://...example.com/api/rest/organization/10 (via GET). This is very
    different from the XML-RPC api we have today where the verbs are part of
    the method call.
  * Alternatively we could use GET and POST, and use an XML-RPC type of methodology. That is, create and post JSON messages.
 * SOAP
  * We will NOT provide a SOAP interface. It is overkill and rather pointless
    to go down this route. Folks like to think they need SOAP because it is
    up2date, but truly it is nothing more than CORBA with angle brackets. 
 * XML-RPC
  * XML-RPC is extremely easy to support and add as we have this type of API in
    many of our products today such as Red Hat Network (hosted) and Satellite.
    Excellent libraries for Java and python.
  * Though XML-RPC has some limitations such as no support for longs or nulls.
  * It also has a reputation for being out of date.

## Resources

 * [JSON-RPC](http://json-rpc.org/)
 * [jersey](https://jersey.dev.java.net/)
 * [JBoss RESTEasy](http://www.jboss.org/resteasy/)
 * [Smugmug API](http://wiki.smugmug.net/display/SmugMug/API)
 * [JSON+REST vs. XML+SOAP](http://blog.feedly.com/2009/03/03/jsonrest-vs-xmlsoap/)
 * [Flickr API](http://www.flickr.com/services/api/)

---
layout: default
title: Federated Certificate Management
---
{% include toc.md %}

# Overview
This is an overview of the issues around Federated Certificate Generation. This
is fancy name for what the On Premise Candlepin will need to do.

# Background
RHUI, Hosted Candlepin/CDN, and Katello all follow a similar pattern:

1. They have their own Certificate Authority (CA)
1. The create certificates using that CA
1. They mirror content from Red Hat, and control access to that content using that CA.

In the case of Hosted Candlepin/CDN Red Hat holds the CA. In the case of RHUI
and Kalpana, the customer would use their own CA. However, in all cases the CA
is used to grant certificates and control access to locally managed Content.

For on premise Candlepin, we would like to have an on premise tool which can
manage certificates but not mirror content. The content would be accessed from
the upstream CDN.

There are a couple of ways to approach this:

## Pre Generate The Certificates

In this model, the hosted environment would generate the certificates using
their on CA. Then, the certificates are given in batch out to the on premise
tool which in turn gives them to the machines which require them. This allows
Red Hat to control the CA, and handle revocation within our own network.
However, products such as EUS require that the certificates be unique based on
other certificates which are on the box. Therefore, it would be difficult to
pre-generate all the valid combination which could be used.

## Sub CAs
A second model would be for the on-premise tool to be a sub CA of the upstream
CA. Technically this is possible. However, this would mean that anyone with a
On premise Candlepin can create certs which can pull content from the upstream
CDN. Red Hat would need to create some robust fraud detection tools to ensure
that we are not giving away the bits. In addition, to support revocation of
certificate, the client would need to send Revoked certificated to the content
provider in order to add to the corporate Certificate Revocation List.

## Proxy Model
A third approach would be for the on premise tool to generate certificate using
a local CA. Some intelligent proxy would need to emit a CDN API, and to
transmorgify a content request using a local certificate into a similar request
which can be handled by the upstream CDN. This would need to include some sort
of certificate replacement.

### Content Cert Proxy

![]({{ site.baseurl }}/images/cs-proxy.png)

One possible solution, following the proxy model, would be be for the On
Premise Server to provide 2 bits of data to a Content Proxy. These are:

1. The Content Certificates which have been loaded into Candlepin from a Subscription Manifest. 
1. Certificate Revocation data in the form of either a CRL or OCSPD.

Yum can then be configured to pull content from that proxy. When a request is
made, the following would need to be done by the proxy:

1. Check that the certificate is value, and has not been revoked.
1. Check that the request is a for a url which is allowed by this certificate.
1. Check that the proxy is configured with a Content Certificate which is also valid and provides access to that repository on the CDN
1. If the above passes, pull down the content from the CDN using the Content Certificate, and provide it back to the requester.

---
categories: design
title: Thumbslug Multi-CDN Design
---
{% include toc.md %}

# Thumbslug Multi-CDN Design

## Goal

Currently thumbslug is configured to talk to one and only one CDN. Goal is to
allow each org to import a manifest which links to a specific CDN which will be
used for that org.

To talk to a CDN we need the following:

* The CDN URL. Currently stored in `thumbslug.conf` as `cdn.host` and
  `cdn.port`.
* The CA certificate to use to verify we're talking to the correct CDN.
  Currently the official CDN CA is included in the thumbslug rpm as
  `/etc/thumbslug/cdn-ca.crt`. Configured by `cdn.ssl.ca.keystore` property.

## Challenges

1. The CDN CA certificate to use in the case of talking to an upstream SAM is
   effectively that servers candlepin-ca.crt. We can assume this certificate is
   on the downstream server as it was needed to verify the manifest during
   import. Candlepin stores these in `/etc/candlepin/certs/upstream/`, there
   are potentially many, and will try each to see if one of them will verify
   the manifest. This is fine for import which is not a critical time sensitive
   operation, however in thumbslug we need to do something similar on the fly
   during requests, checking each certificate is probably not going to be
   feasible.
1. Thumbslug's only communication with Candlepin today is to fetch the upstream
   certificate for an incoming entitlement cert. The response is just the PEM
   text of the cert. However if we now need to look up the CDN URL, as well as
   the filename of the upstream cert to verify the CDN with, we will likely
   need to start doing JSON processing. This means new dependencies and added
   complexity in Thumbslug.

## Design
1. Add a new parameter to import API allowing caller to specify the CDN URL to use in the next step.
   * If not specified, default to the current official URL: https://cdn.redhat.com:443
   * Import API is at: `OwnerResource.importManifest`
   * Katello/SAM will provide this when they generate a manifest, the CDN URL is already known there.
1. Export the CDN URL in manifests.
   * See the "Meta" class, this is very similar to webAppPrefix which is carried there today.
   * Property name: cdnUrl
1. Store the incoming cdnUrl on the `UpstreamConsumer` class during import.
   1. Store the filename of the CA certificate that successfully verified the
      manifest during import on the `UpstreamConsumer` class.
      * Remember that a manifest signature conflict may have been forced. This
        feature may need to be removed, as Thumbslug cannot function without
        this without disabling SSL verification.
      * The files are processed in
        `PKIUtility.verifySHA256WithRSAHashAgainstCACerts`. Will need to get a
        filename out of here and back to `Importer.loadExport`.
      * Handle scenario where the certificate has since been deleted/moved.
   1. Add a new API call for Thumbslug to fetch the CDN URL and CA certificate
      filename to use: GET /entitlements/{entId}/cdn_info
      * CDN Info would be a new DTO object which contains everything Thumbslug
        needs to make a request. (upstream entitlement cert, CDN URL, CDN
        certificate filename/path)
      * This effectively replaces /entitlements/{entId}/upstream_cert Thumbslug
        uses now, investigate if we can remove it.
      * Avoids the overhead of 2-3 API calls made for each request.
      * Thumbslug only knows the entitlement ID it gets from the entitlement certificate subject a client is using.
      * Data fetched by going from entitlement -> pool -> owner -> upstream consumer.
   1. Add Jackson dependencies to Thumbslug RPM.
      * Currently Thumbslug just gets the upstream cert as plain text. We need to be able to parse the CDN info.
   1. Use new cdn_info API call in Thumsblug.
      * Replace use of GET /entitlements/{entId}/upstream_cert in `HttpRequestHandler`.
      * Parse as JSON.
      * We do not have to worry about thumbslug / candlepin compatability or
        backward compatability, as the two are always deployed together.
      * TODO: investigate how often this is called. It looks like once per http
        request, is performance still acceptable with the extra data in the API
        call, and the added reading of the CDN SSL cert from disk? Do we need
        to cache these?
   1. Use new cdn_info when making the SSL connection in Thumbslug.
      * See: `HttpCdnClientChannelFactory`
      * The CDN SSL certificate was previously coming from the
        cdn.ssl.ca.keystore property. This should still be used as the default
        if we were unable to fetch any.
      * Same goes for cdn.host and cdn.port settings. 

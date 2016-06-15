---
title: Manifests
---

# Manifests

Manifests facilitate a means to easily transfer subscriptions from a hosted candlepin server to an on-premis, or stand-alone instance. A distributor consumer's entitlements can be exported into a manifest file which can then be imported into an on-premis candlepin resulting in subscriptions that can then be used by on-premis consumers (systems).

{% plantuml %}
left to right direction
skinparam packageStyle rect

rectangle "Hosted Candlepin" {
(Manifest File) as manifest1
(Distributor) .> (manifest1) : "exported as"
}

rectangle "On-Premis Candlepin" {
(Manifest File) as manifest2
(Subscriptions)
}

actor User

User .> (Distributor) : exports
manifest1 .> User : downloaded by

User .> manifest2 : uploads
manifest2 .> (Subscriptions) : imported as

{% endplantuml %}

### Basic Workflow

1. User creates a distributor on the hosted candlepin server and attaches entitlements to it.
1. User exports the distributor.
1. User downloads the manifest file.
1. User uploads the manifest file to an on-premis candlepin server where it is imported and results in available subscriptions.

# Deprecated APIs

In Candlepin versions prior to 2.1, the import/export APIs were synchronous and have since been made asynchronous. In version 2.1 and beyond, the asynchronous APIs should be used exclusively. While the old APIs remain functional, clients should be updated to use the new version. Newer import/export functionality will not be supported in the deprecated APIs going forward.

To learn about the the updated APIs, see:

1. [Exporting A Manifest]({{ site.url }}/docs/candlepin/manifest_export.html)
2. [Importing A Manifest]({{ site.url }}/docs/candlepin/manifest_import.html)

The deprecated APIs are:

1. Export [GET /consumers/:uuid/export]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/consumers/exportData){:target="_blank"}
1. Import [POST /owners/:key/imports]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/importManifest){:target="_blank"}



---
title: Exporting A Manifest
---
{% include toc.md %}

# Exporting A Manifest

In order for a consumer to be exported, it must be manfest enabled. We refer to this type of consumer as a distributor. A consumer is considered to be a distributor if its ConsumerType defines 'manifest':true. Any entitlements attached to a distributor will be included in the manifest when it is exported.

To export a manifest for a distributor, you use the [GET /consumers/:uuid/export/async]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/exportDataAsync){:target="_blank"} API. When the export request is made, candlepin will start an asynchronous job that will perform the export. When the job is complete, the job status will provide the details of how the export can be obtained using the [GET /consumers/:uuid/export/:export_id]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/downloadExistingExport){:target="_blank"} API.

It is important to note that only one manifest can be generated per distributor at a time. Any subsequent manifest generations will invalidate the previously generated manifest. Also, once a manifest is generated, it may only be downloaded once, and must be regenerated again in order to obtain another file. All generated manifest files that are not downloaded will remain on the candlepin server for a [configurable](https://github.com/candlepin/candlepin/blob/master/server/src/main/java/org/candlepin/config/ConfigProperties.java) amount of time (24 hour default).


### Example

```bash
# *******************************************************
# An example of exporting a consumer via curl.
#
# Distributor UUID: 1dc9d30a-cb39-4155-8789-c6efb0061b42
# *******************************************************
# Initiate the export of the distributor with UUID CONSUMER_UUID
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/consumers/1dc9d30a-cb39-4155-8789-c6efb0061b42/export/async
{
  "id" : "export_f82ed540-6811-4aa1-a1d5-652c37c964f5",
  "state" : "CREATED",
  "startTime" : null,
  "finishTime" : null,
  "result" : null,
  "principalName" : "admin",
  "targetType" : "consumer",
  "targetId" : "1dc9d30a-cb39-4155-8789-c6efb0061b42",
  "ownerId" : "admin",
  "resultData" : null,
  "statusPath" : "/jobs/export_f82ed540-6811-4aa1-a1d5-652c37c964f5",
  "done" : false,
  "group" : "async group",
  "created" : "2016-06-15T19:01:41+0000",
  "updated" : "2016-06-15T19:01:41+0000"
}

# Check the status of the reported job and get the info required to download the manifest.
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/jobs/export_f82ed540-6811-4aa1-a1d5-652c37c964f5?result_data=true
{
  "id" : "export_f82ed540-6811-4aa1-a1d5-652c37c964f5",
  "state" : "FINISHED",
  "startTime" : "2016-06-15T19:01:41+0000",
  "finishTime" : "2016-06-15T19:01:42+0000",
  "result" : "org.candlepin.sync.ExportResult@151f308d",
  "principalName" : "admin",
  "targetType" : "consumer",
  "targetId" : "1dc9d30a-cb39-4155-8789-c6efb0061b42",
  "ownerId" : "admin",
  "resultData" : {
    "exportedConsumer" : "1dc9d30a-cb39-4155-8789-c6efb0061b42",
    "exportId" : "402882e7554b512901555570c667098a",
    "href" : "/consumers/1dc9d30a-cb39-4155-8789-c6efb0061b42/export/402882e7554b512901555570c667098a"
  },
  "statusPath" : "/jobs/export_f82ed540-6811-4aa1-a1d5-652c37c964f5",
  "done" : true,
  "group" : "async group",
  "created" : "2016-06-15T19:01:41+0000",
  "updated" : "2016-06-15T19:01:42+0000"
}

# Download the manifest using the data from the job result (resultData).
$ wget --content-disposition --user admin --password admin https://localhost:8443/candlepin/consumers/1dc9d30a-cb39-4155-8789-c6efb0061b42/export/402882e7554b512901555570c667098a
Saving to: ‘1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip’

```

# The Anatomy Of A Manifest File

A manifest file contains all of the data from the upstream candlepin required to move entitlements from one candlepin to another. It is simply a signed zip file containing various bits of data.

Extracting a manifest file yields:

- **consumer_export.zip:** An archive of the expored consumer data.
- **signature:** The signature for the consumer_export.zip file.

The contents of the consumer_export.zip file are as follows:

|**File/Directory**|**Description**|
|consumer_types|This directory contains individual JSON files for all of the consumer types in the source candlepin instance. TODO: Why are they all needed?|
|distributor_version|This directory contains individual JSON files for all of the distributor versions available in the source candlepin. TODO: Why are they all needed?|
|entitlement_certificates|This directory contains the actual certificated (PEM files) for each entitlement that was attacted to the distributor at the time of the export.|
|entitlements|This directory contains individual JSON files for each entitlement that was attached to the distributor at the time of the export. These should be 1-1 with the entitlement certificates.|
|products|This directory contains all of the product certificates (as well as a JSON file) that are referenced by the incoming entitlements. These products will be imported into candlepin and associated with the target Owner.|
|rules|This directory contains the legacy version of the candlepin rules JS file (default-rules.js)|
|rules2|This directory contains the active version of the candlepin rules JS file (rules.js). On import, candlepin will check if it has an older version of this rules file, and will update it if required.|
|upstream_consumer|This directory contains the identity certificate for the distributor that was exported.|
|extenstions|This is where custom manifest extension files are placed (v2.1+)|
|consumer.json|This file is a JSON representation of the distributor consumer.|
|meta.json|This file contains meta-data about the manifest file. It contains data such as the version of candlepin that created the manifest and who created it.|


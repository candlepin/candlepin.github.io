---
title: Importing A Manifest
---
{% include toc.md %}

# Importing A Manifest

When a manifest file is imported into an on-premis candlepin, it is imported into a target candlepin Owner. All of the distributor's entitlements are translated into Pools (subscriptions) from which registered systems (consumers) can attach entitlements.

To import a manifest into an on-premis candlepin, you need to first determine which Owner you are going to import the manifest into. You can list the available Owners via the [GET /owners]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/list){:target="_blank"} API. Once you have the owner key, you can import the manifest using the [POST /owners/:key/imports/async]({{ site.url }}/swagger/?url=candlepin/swagger-2.0.13.json#!/owners/importManifestAsync){:target="_blank"} API.

When an import request is made, candlepin will start an asynchronous job to perform the import. Only one import job can be in progress, per Owner, at a time. The job status will provide the details of the import job and can be monitored.

### Example

```bash
# ********************************************
# An example of importing a manifest via curl.
# ********************************************
#
# List all available owners for the user.
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/owners
[
    {
      "parentOwner" : null,
      "id" : "402882e7554b512901555578ae49098c",
      "key" : "my_owner",
      "displayName" : "my_owner",
      "contentPrefix" : null,
      "defaultServiceLevel" : null,
      "upstreamConsumer" : null,
      "logLevel" : null,
      "href" : "/owners/my_owner",
      "created" : "2016-06-15T19:10:20+0000",
      "updated" : "2016-06-15T19:10:20+0000"
    }
]

# Import a manifest file into the 'my_owner' owner.
$ curl -k -X POST -F "application/zip=@1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip" -u USERNAME:PASSWORD https://localhost:8443/candlepin/owners/my_owner/imports/async
{
  "id" : "import_8b018fd9-679a-4e2e-8704-2eac757b35a8",
  "state" : "CREATED",
  "startTime" : null,
  "finishTime" : null,
  "result" : null,
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : null,
  "statusPath" : "/jobs/import_8b018fd9-679a-4e2e-8704-2eac757b35a8",
  "done" : false,
  "group" : "async group",
  "created" : "2016-06-15T19:16:52+0000",
  "updated" : "2016-06-15T19:16:52+0000"
}

# Monitor the job status to see when the job has completed
# and if it was successful.
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/jobs/import_8b018fd9-679a-4e2e-8704-2eac757b35a8?result_data=true
{
  "id" : "import_8b018fd9-679a-4e2e-8704-2eac757b35a8",
  "state" : "FINISHED",
  "startTime" : "2016-06-15T19:16:52+0000",
  "finishTime" : "2016-06-15T19:16:53+0000",
  "result" : "org.candlepin.model.ImportRecord@423ceee3",
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : {
    "id" : "402882e7554b51290155557ead2f09c9",
    "status" : "SUCCESS",
    "statusMessage" : "my_owner file imported successfully.",
    "fileName" : "1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip",
    "generatedBy" : "admin",
    "generatedDate" : "2016-06-15T19:01:42+0000",
    "upstreamConsumer" : {
      "id" : "402882e7554b51290155557ead2f09ca",
      "uuid" : "1dc9d30a-cb39-4155-8789-c6efb0061b42",
      "name" : "bluestar",
      "type" : {
        "id" : "1003",
        "label" : "candlepin",
        "manifest" : true
      },
      "ownerId" : "402882e7554b512901555578ae49098c",
      "webUrl" : "localhost:8443/candlepin",
      "apiUrl" : "localhost:8443/candlepin",
      "created" : "2016-06-15T19:16:53+0000",
      "updated" : "2016-06-15T19:16:53+0000"
    },
    "created" : "2016-06-15T19:16:53+0000",
    "updated" : "2016-06-15T19:16:53+0000"
  },
  "statusPath" : "/jobs/import_8b018fd9-679a-4e2e-8704-2eac757b35a8",
  "done" : true,
  "group" : "async group",
  "created" : "2016-06-15T19:16:52+0000",
  "updated" : "2016-06-15T19:16:53+0000"
}
```

# Conflict Overrides

When a manifest is imported, candlepin may report that it has a conflict(s). These conflicts will be present in the import job details.

### Possible Conflicts

|**Conflict Key**|**Description**|
|MANIFEST_OLD|Manifest is older than the last imported manifest.|
|MANIFEST_SAME|The imported manifest is the same as the last imported manifest.|
|DISTRIBUTOR_CONFLICT|A manifest has already been imported into the target Owner, and the Owner's upstream consumer (distributor) does not match that of the incoming manifest.|
|SIGNATURE_CONFLICT|The incoming manifest has failed the signature check and may have been tampered with.|

These conflicts can be overridden/ignored by specifying 'force' query parameters when making an import request. The value of the force parameter will be any of the conflict keys in the table above.

**Caution should be used when using the conflict override feature.**
{:.alert-bad}

### Example

```bash
# ********************************************
# An example of importing a manifest via curl
# and overriding a conflict.
# ********************************************

# Import a manifest file into the owner.
$ curl -k -X POST -F "application/zip=@1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip" -u USERNAME:PASSWORD https://localhost:8443/candlepin/owners/my_owner/imports/async
{
  "id" : "import_fa9fca61-e058-4266-9237-5fdbd721304e",
  "state" : "CREATED",
  "startTime" : null,
  "finishTime" : null,
  "result" : null,
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : null,
  "statusPath" : "/jobs/import_fa9fca61-e058-4266-9237-5fdbd721304e",
  "done" : false,
  "group" : "async group",
  "created" : "2016-06-15T19:19:28+0000",
  "updated" : "2016-06-15T19:19:28+0000"
}

# Monitor the job status to see that the job had failed
# with conflicts (resultData.conflicts).
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/jobs/import_fa9fca61-e058-4266-9237-5fdbd721304e?result_data=true
{
  "id" : "import_fa9fca61-e058-4266-9237-5fdbd721304e",
  "state" : "FAILED",
  "startTime" : "2016-06-15T19:19:28+0000",
  "finishTime" : null,
  "result" : "Import is the same as existing data",
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : {
    "displayMessage" : "Import is the same as existing data",
    "requestUuid" : "import_fa9fca61-e058-4266-9237-5fdbd721304e",
    "conflicts" : [ "MANIFEST_SAME" ]
  },
  "statusPath" : "/jobs/import_fa9fca61-e058-4266-9237-5fdbd721304e",
  "done" : true,
  "group" : "async group",
  "created" : "2016-06-15T19:19:28+0000",
  "updated" : "2016-06-15T19:19:28+0000"
}

# Try the import again forcing an override.
$ curl -k -X POST -F "application/zip=@1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip" -u USERNAME:PASSWORD https://localhost:8443/candlepin/owners/my_owner/imports/async?force=MANIFEST_SAME
{
  "id" : "import_becc3006-eedb-4e4c-838c-95fcd5288473",
  "state" : "CREATED",
  "startTime" : null,
  "finishTime" : null,
  "result" : null,
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : null,
  "statusPath" : "/jobs/import_becc3006-eedb-4e4c-838c-95fcd5288473",
  "done" : false,
  "group" : "async group",
  "created" : "2016-06-15T19:22:49+0000",
  "updated" : "2016-06-15T19:22:49+0000"
}

# Monitor the job status to see that the job has completed
# successfully.
$ curl -k -u USERNAME:PASSWORD https://localhost:8443/candlepin/jobs/import_becc3006-eedb-4e4c-838c-95fcd5288473?result_data=true
{
  "id" : "import_becc3006-eedb-4e4c-838c-95fcd5288473",
  "state" : "FINISHED",
  "startTime" : "2016-06-15T19:22:49+0000",
  "finishTime" : "2016-06-15T19:22:49+0000",
  "result" : "org.candlepin.model.ImportRecord@2ffc2413",
  "principalName" : "admin",
  "targetType" : "owner",
  "targetId" : "my_owner",
  "ownerId" : "my_owner",
  "resultData" : {
    "id" : "402882e7554b5129015555841d4f09dc",
    "status" : "SUCCESS",
    "statusMessage" : "my_owner file imported forcibly.",
    "fileName" : "1dc9d30a-cb39-4155-8789-c6efb0061b42-export.zip",
    "generatedBy" : "admin",
    "generatedDate" : "2016-06-15T19:01:42+0000",
    "upstreamConsumer" : {
      "id" : "402882e7554b5129015555841d4f09dd",
      "uuid" : "1dc9d30a-cb39-4155-8789-c6efb0061b42",
      "name" : "bluestar",
      "type" : {
        "id" : "1003",
        "label" : "candlepin",
        "manifest" : true
      },
      "ownerId" : "402882e7554b512901555578ae49098c",
      "webUrl" : "localhost:8443/candlepin",
      "apiUrl" : "localhost:8443/candlepin",
      "created" : "2016-06-15T19:22:49+0000",
      "updated" : "2016-06-15T19:22:49+0000"
    },
    "created" : "2016-06-15T19:22:49+0000",
    "updated" : "2016-06-15T19:22:49+0000"
  },
  "statusPath" : "/jobs/import_becc3006-eedb-4e4c-838c-95fcd5288473",
  "done" : true,
  "group" : "async group",
  "created" : "2016-06-15T19:22:49+0000",
  "updated" : "2016-06-15T19:22:49+0000"
}

```



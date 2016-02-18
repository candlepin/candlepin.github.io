---
categories: usage
title: Batch binding exact pools
---
{% include toc.md %}

## Overview
* Candlepin 2.0 provides a convinience API to bind a batch of exact pools by respective quantities. This document shows the usage and example responses of that API.
* Batch bind requests are asynchronous only.
* The requests are atomic. If any of the pools and respective quantities requested fails for any reason ( including java script validation ), the entire operation fails and none of the pools are consumed.

## Request
* The request takes in an array of `PoolIdAndQuantity` objects, which associate the id of the pool requested to be consumed and the respective requested quantity
* Example batch bind REST request:

  ```text
  url: POST candlepin/consumers/{consumer_uuid}/entitlements?async=true
  body: [ {"poolId":"ff80808152efb6a70152f12fd06e0338", "quantity":1},
          {"poolId":"ff80808152efb6a70152f12fd0130335", "quantity":3},
           .
           .
           .
          {"poolId":"ff80808152efb6a70152f12fcf54032f", "quantity":1},
          {"poolId":"ff80808152efb6a70152f12fcef0032c", "quantity":8}
        ]
  ```
* This REST request creates and schedules an asynchronous job to bind the pools, and returns a `JobStatus` with the id of the job created

  ```text
  {
    "id": "bind_by_pool_1cfdedb3-05aa-444a-814a-aabc5afedba4",
    "state": "CREATED",
    "startTime": null,
    "finishTime": null,
    "result": null,
    "principalName": "admin",
    "targetType": "consumer",
    "targetId": "{consumer_uuid}",
    "ownerId": "{owner_key}",
    "resultData": null,
    "statusPath": "/jobs/bind_by_pool_1cfdedb3-05aa-444a-814a-aabc5afedba4",
    "done": false,
    "group": "async group",
    "created": "2016-02-17T23:22:17+0000",
    "updated": "2016-02-17T23:22:17+0000"
  }
  ```
* The user of this API can check the result and the status the job using the url:

  ```text
  url: GET https://localhost:8443/candlepin/jobs/bind_by_pool_1cfdedb3-05aa-444a-814a-aabc5afedba4?result_data=true
  ```

## Succesful Response
* Upon success, the `resultData` on the `JobStatus` enlists a `PoolIdAndQuantity` for each pool consumed with the respective quantity consumed

  ```text
  {
    "id": "bind_by_pool_1cfdedb3-05aa-444a-814a-aabc5afedba4",
    "state": "FINISHED",
    "startTime": "2016-02-17T23:22:17+0000",
    "finishTime": "2016-02-17T23:22:18+0000",
    "result": "[Lorg.candlepin.model.dto.PoolIdAndQuantity;@17d03e3a",
    "principalName": "admin",
    "targetType": "consumer",
    "targetId": "aabca0d1-1b44-4167-92f6-5da7ded68b33",
    "ownerId": "consumertest-61066",
    "resultData": [
      {
        "poolId": "ff80808152efb6a70152f12fd06e0338",
        "quantity": 1
      },
      {
        "poolId": "ff80808152efb6a70152f12fcfb30332",
        "quantity": 1
      },
      .
      .
      .
      {
        "poolId": "ff80808152efb6a70152f12fcef0032c",
        "quantity": 1
      },
      {
        "poolId": "ff80808152efb6a70152f12fd0130335",
        "quantity": 1
      }
    ],
    "statusPath": "/jobs/bind_by_pool_1cfdedb3-05aa-444a-814a-aabc5afedba4",
    "done": true,
    "group": "async group",
    "created": "2016-02-17T23:22:17+0000",
    "updated": "2016-02-17T23:22:18+0000"
  }
  ```

## Failure Response
* If the job fails, the `result` section on the `JobStatus` returns the failure message.
* Note: The job is considered `FAILED` only if the bind process results in unexpected errors, Which is not the same as if the request fails pre-entitlement java script rules check ( view next section ).

  ```text
  {
    "id": "bind_by_pool_984f29e0-fff0-4175-9c23-1d3cb0d1d842",
    "state": "FAILED",
    "startTime": "2016-02-17T23:45:31+0000",
    "finishTime": null,
    "result": "Subscription pool(s) [ThisIDdoesNOTexist, NEITHERdoesTHIS] do not exist.",
    "principalName": "admin",
    "targetType": "consumer",
    "targetId": "aabca0d1-1b44-4167-92f6-5da7ded68b33",
    "ownerId": "consumertest-61066",
    "resultData": null,
    "statusPath": "/jobs/bind_by_pool_984f29e0-fff0-4175-9c23-1d3cb0d1d842",
    "done": true,
    "group": "async group",
    "created": "2016-02-17T23:45:31+0000",
    "updated": "2016-02-17T23:45:32+0000"
  }
  ```

## Validation Errors
* If any of the `PoolIdAndQuantity` requested to be consumed fails java script validation for pre-entitlement rules check, the `resultData` on the `JobStatus` enlists a `PoolIdAndErrors` for each pool that failed validation.
* Each `PoolIdAndErrors` contains the pool id of the pool that failed validation, and ALL the reasons due to which that pool failed validation

  ```text
  {
    "id": "bind_by_pool_9c8bcc04-9c27-4086-9f6a-f82bcd3568ad",
    "state": "FINISHED",
    "startTime": "2016-02-17T23:40:33+0000",
    "finishTime": "2016-02-17T23:40:33+0000",
    "result": "[org.candlepin.model.dto.PoolIdAndErrors@49df3c1f, org.candlepin.model.dto.PoolIdAndErrors@c7fc5ed, org.candlepin.model.dto.PoolIdAndErrors@37dfc800, org.candlepin.model.dto.PoolIdAndErrors@5adde4e6]",
    "principalName": "admin",
    "targetType": "consumer",
    "targetId": "aabca0d1-1b44-4167-92f6-5da7ded68b33",
    "ownerId": "consumertest-61066",
    "resultData": [
      {
        "poolId": "ff80808152efb6a70152f12fcef0032c",
        "errors": [
          "No subscriptions are available from the pool with ID 'ff80808152efb6a70152f12fcef0032c'."
        ]
      },
      {
        "poolId": "ff80808152efb6a70152f12fcfb30332",
        "errors": [
          "No subscriptions are available from the pool with ID 'ff80808152efb6a70152f12fcfb30332'."
        ]
      },
      {
        "poolId": "ff80808152efb6a70152f12fd0130335",
        "errors": [
          "No subscriptions are available from the pool with ID 'ff80808152efb6a70152f12fd0130335'."
        ]
      },
      {
        "poolId": "ff80808152efb6a70152f12fd06e0338",
        "errors": [
          "No subscriptions are available from the pool with ID 'ff80808152efb6a70152f12fd06e0338'."
        ]
      }
    ],
    "statusPath": "/jobs/bind_by_pool_9c8bcc04-9c27-4086-9f6a-f82bcd3568ad",
    "done": true,
    "group": "async group",
    "created": "2016-02-17T23:40:33+0000",
    "updated": "2016-02-17T23:40:33+0000"
  }
  ```

## Configs

* Here are two candlepin configs with their current defaults relevant to this API:
* Number of concurrent jobs:

  ```text
  pinsetter.EntitlerJob.throttle = 7
  ```
  * `pinsetter.EntitlerJob.throttle` controls the number of entitler jobs that can run concurrently. Because the requests are fulfilled by the same job, this config effects not only the newer batch API, but also the asynchronous requests that request binding a single pool with the url:

  ```text
  url: POST candlepin/consumers/{consumer_uuid}/entitlements?async=true&pool={pool_id}&quantity={quantity}
  ```

* Maximum number of pools allowed to be requested per bind request:

  ```text
  candlepin.batch.bind.max.size = 100
  ```

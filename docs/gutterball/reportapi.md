---
title: Reporting API
---
{% include toc.md %}

# Reporting API

## ReportsResource
Defines the API for running the reports.

**GET /reports**

List the available reports and the metadata associated with them.

**GET /reports/{report_key}**

List the details of the report specified by {report_key}

**GET /reports/{report_key}/run?param1=v1&param2=v2**

Run the report specified by {report_key} using the specified query parameters.
Query parameters can be multi-valued.

### Parameter Validation
When a report is run, all specified parameters will be validated. GB will raise a BadParameterExcpetion which will be handled and return useful error data back to the client.

```json
{
  "displayMessage" : "on_date: Invalid date string. Expected format: yyyy-MM-dd'T'HH:mm:ss.SSSZ",
  "requestUuid" : "6fbd6cc8-1838-43f7-a4d8-7a759e47aa02"
}
```

## Current Reports

### Consumer Status Report

Lists the latest compliance status of consumers who have reported compliance during a specified time period.

#### **GET /reports/consumer_status**

Current details of the report parameters.

```json
{
  "key" : "consumer_status",
  "description" : "List the status of all consumers",
  "parameters" : [ {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "consumer_uuid",
    "description" : "Filters the results by the specified consumer UUID."
  }, {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "owner",
    "description" : "The Owner key(s) to filter on."
  }, {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "status",
    "description" : "The subscription status to filter on [valid, invalid, partial]."
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "on_date",
    "description" : "The date to filter on. Defaults to NOW."
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "product_name",
    "description" : "The name of a product on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "sku",
    "description" : "The entitlement sku on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "subscription_name",
    "description" : "The name of a subscription on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "management_enabled",
    "description" : "Filter on subscriptions which have management enabled set to this value (boolean)"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "custom_results",
    "description" : "Enables/disables custom report result functionality via attribute filtering (boolean)."
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "include_reasons",
    "description" : "Include status reasons in results"
  }, {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "include",
    "description" : "Includes the specified attribute in the result JSON"
  }, {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "exclude",
    "description" : "Excludes the specified attribute in the result JSON"
  } ]
}
```

**NOTES:**

1. Uses a minimized result DTO meaning that by default it does not return all data associated with a compliance snapshot. This is done to minimize the amount of unneeded data serialized in the response, improving performance. If more data is required, you can use the attribute filtering feature. [ [Read More](reportapi.html#custom-response-filtering-attribute-filtering) ]
2. Running the report with no paramters will return all compliance status records for all reported consumers.
3. When specifying the **on_date** paramter, results will be limited to compliance status records that were last reported before or on that date.
4. Generally **status** values from candlepin will be one of: valid, partial, invalid

#### **GET /reports/consumer_status/run?owner=acme_corporation**

An example of running the report filtering by owner key.

**Report Output**

```json
{
  "status" : {
    "status" : "valid",
    "date" : "2015-02-09T13:27:40.652+0000"
  },
  "consumer" : {
    "facts" : {
        "cpu.core(s)_per_socket": "4",
        "cpu.cpu(s)": "4",
        "cpu.cpu_socket(s)": "1",
        "cpu.thread(s)_per_core": "1"
    },
    "consumerState" : {
      "created" : "2015-02-09T13:27:35.578+0000",
      "deleted" : null
    },
    "name" : "test-consumer-BEcQrEdg",
    "owner" : {
      "displayName" : "ACME Corporation",
      "key" : "acme_corporation"
    },
    "lastCheckin" : "2015-02-09T13:27:37.809+0000",
    "uuid" : "0668eca4-2efe-4965-a2ea-610027164c4e"
  }
}
```

### Consumer Trend Report

Lists ALL compliance snapshots for a consumer who has reported compliance status in the specified time period.

#### **GET /reports/consumer_trend**

Current details of the report parameters.

```json
  "key" : "consumer_trend",
  "description" : "Lists the status of each consumer over a date range",
  "parameters" : [ {
    "mandatory" : true,
    "multiValued" : false,
    "description" : "Filters the results by the specified consumer UUID.",
    "name" : "consumer_uuid"
  }, {
    "mandatory" : false,
    "multiValued" : false,
    "description" : "The number of hours to filter on (used indepent of date range).",
    "name" : "hours"
  }, {
    "mandatory" : false,
    "multiValued" : false,
    "description" : "The start date to filter on (used with end_date).",
    "name" : "start_date"
  }, {
    "mandatory" : false,
    "multiValued" : false,
    "description" : "The end date to filter on (used with start_date)",
    "name" : "end_date"
  }, {
    "mandatory" : false,
    "multiValued" : false,
    "description" : "Enables/disables custom report result functionality via attribute filtering (boolean).",
    "name" : "custom_results"
  }, {
    "mandatory" : false,
    "multiValued" : true,
    "description" : "Includes the specified attribute in the result JSON",
    "name" : "include"
  }, {
    "mandatory" : false,
    "multiValued" : true,
    "description" : "Excludes the specified attribute in the result JSON",
    "name" : "exclude"
  } ]
```

**NOTES:**

1. Uses a minimized result DTO meaning that by default it does not return all data associated with a compliance snapshot. This is done to minimize the amount of unneeded data serialized in the response, improving performance. If more data is required, you can use the attribute filtering feature. [ [Read More](reportapi.html#custom-response-filtering-attribute-filtering) ]
2. Report result is a map of consumer_uuid to list of compliance snapshots.
3. Parameters allow limiting results to a specific consumer during a period of time.
4. Specifying no time period results in ALL known snapshots for the specified consumer.

#### **GET /reports/consumer_trend/run?consumer_uuid=5c2e62d3-9e01-40ca-aa83-c02a8635a9e7&hours=24**

An example of running the report for a consumer and returning snapshots for the last 24 hours.

**Result Output**

```json
[ {
  "status" : {
    "status" : "invalid",
    "reasons" : [ {
      "message" : "Not supported by a valid subscription.",
      "attributes" : {
        "product_id" : "37060",
        "name" : "Awesome OS Server Bits"
      }
    } ],
    "date" : "2015-02-09T16:41:54.116+0000"
  },
  "consumer" : {
    "lastCheckin" : null,
    "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7"
  }
}, {
  "status" : {
    "status" : "valid",
    "reasons" : [ ],
    "date" : "2015-02-10T13:36:47.074+0000"
  },
  "consumer" : {
    "lastCheckin" : "2015-02-10T13:36:44.104+0000",
    "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7"
  }
} ]

```

### Status Trend Report

The status trend report shows the per-day counts of consumers, grouped by status, optionally
limited to a date range and/or filtered by select criteria.

#### **GET /reports/status_trend**

Current details of the report parameters.

```json
{
  "key" : "status_trend",
  "description" : "Lists the per-day status counts for all consumers",
  "parameters" : [ {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "start_date",
    "description" : "The start date on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "end_date",
    "description" : "The end date on which to filter"
  }, {
    "multiValued" : true,
    "mandatory" : false,
    "name" : "consumer_uuid",
    "description" : "The consumer UUID(s) on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "owner",
    "description" : "An owner key on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "product_name",
    "description" : "The name of a product on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "sku",
    "description" : "The entitlement sku on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "subscription_name",
    "description" : "The name of a subscription on which to filter"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "management_enabled",
    "description" : "Filter on subscriptions which have management enabled set to this value (boolean)"
  }, {
    "multiValued" : false,
    "mandatory" : false,
    "name" : "timezone",
    "description" : "The timezone to use when processing the request and returning results"
  } ]
}
```

**NOTES:**

1. The status trend report returns a map of maps; the outer map using dates as keys mapped to
    maps of status strings to per-day counts.
2. Statuses returned are always in lower case, and the date/times returned represent the time
    relative to the server's local time, by default.
3. Timestamps can be returned in other time zones by using the 'timezone' query param.
  *  Time zones must be recognized time zone names or offsets specified in the form of \"GMT[+-]HH:?MM\".
3. A consumer's status is counted on each day returned in the report; even if that consumer was not
    able to submit a compliance report for that day. In such a case, the consumer's status is
    extrapolated from their last known status.
4. Start and end date does not need to be used in conjunction. When specifying only one, the boundaries
    of the resultant data will be used for the omitted part of the range.
4. Parameters allow limiting results to specific date ranges or filtering by organization owner,
    product name, entitlement sku, subscription name or whether or not the consumer is using
    entitlements which have management enabled.

#### **GET /reports/status_trend/run?timezone=GMT&sku=awesomeos-instancebased**

An example of running the report filtering by subscription sku, returning results in GMT.

```json
{
  "2014-11-03T04:59:59.999+0000" : {
    "valid" : 1
  },
  "2014-11-04T04:59:59.999+0000" : {
    "valid" : 1
  },
  "2014-11-05T04:59:59.999+0000" : {
    "valid" : 2
  },
  "2014-11-06T04:59:59.999+0000" : {
    "valid" : 2
  },
  "2014-11-07T04:59:59.999+0000" : {
    "valid" : 2
  },
  "2014-11-08T04:59:59.999+0000" : {
    "valid" : 2
  },
  "2014-11-09T04:59:59.999+0000" : {
    "valid" : 2
  }
}
```

#### **GET /reports/status_trend/run?subscription_name=Awesome%20OS%20Instance%20Based%20(Standard%20Support)**

An example of running the report filtering by subscription name.

```json
{
  "2014-11-03T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-04T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-05T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-06T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-07T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-08T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-09T04:59:59.999-0500" : {
    "valid" : 2
  }
}
```

#### **GET /reports/status_trend/run?start_date=2014-11-05**

An example of running the report filtering by start date.

```json
{
  "2014-11-05T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-06T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-07T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-08T04:59:59.999-0500" : {
    "valid" : 2
  },
  "2014-11-09T04:59:59.999-0500" : {
    "valid" : 2
  }
}
```

#### **GET /reports/status_trend/run?end_date=2014-11-05**

An example of running the report filtering by end date.

```json
{
  "2014-11-03T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-04T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-05T04:59:59.999-0500" : {
    "valid" : 2
  }
}
```

#### **GET /reports/status_trend/run?management_enabled=true**

An example of running the report filtering by subscriptions with management enabled.

```json
{
  "2014-11-07T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-08T04:59:59.999-0500" : {
    "valid" : 1
  },
  "2014-11-09T04:59:59.999-0500" : {
    "valid" : 1
  }
}
```

## Pagination

Gutterball reports support paging via use of query parameters and the Link header in the response.

You can specify four parameters that affect paging.

page
: The page to request.  Must be greater than zero.

per_page
: The number of results to include per page.  Defaults to 10.

order
: The order to sort the results in.  Can be "asc", "desc", "ascending", or
"descending" (case insensitive).  Defaults to descending.

sort_by
: The field to sort the data by.  Defaults to the created date.

The **_order_** and **_sort_by_** options can alternately be specified without the
**_page_** and **_per_page_** parameters.  In this case, all the results will be
returned sorted in the manner specified by the parameter values.

### Warning
{:.alert-bad .no_toc}

When paging a report that specifies an open-ended date range (now), you run the risk of
report data changing between page requests, since the value of 'now' changes each time the next page is
requested -- fetching new data that gutterball may have collected between page requests.

This can be alleviated by locking down the the date range of the report via its parameters. For example,
the client might determine the value of '_now_' and specify it as an end date along with the paging detail.

An example for the consumer status report might look like the following.

```bash
# Current client time
$ date
Wed Feb 11 07:56:16 AST 2015

# The request can be made by substituting this date for each request.
GET gutterball/reports/consumer_status/run?on_date=2015-02-11T07%3A56%3A16.000-0400&page=4

```


## Custom Response Filtering (attribute filtering)

Generally, each report response returns a JSON representation of a compliance snapshot, whether it be a single
snapshot or a collection of them.

```json
[
    {
        "consumer": {
            "entitlementCount": 1,
            "entitlementStatus": "valid",
            "environment": null,
            "facts": {
                "cpu.core(s)_per_socket": "4",
                "cpu.cpu(s)": "4",
                "cpu.cpu_socket(s)": "1",
                "cpu.thread(s)_per_core": "1"
            },
            "guestIds": [],
            "hypervisorId": null,
            "installedProducts": [
                {
                    "arch": "ALL",
                    "endDate": null,
                    "productId": "37060",
                    "productName": "Awesome OS Server Bits",
                    "startDate": null,
                    "status": null,
                    "version": "6.1"
                }
            ],
            "lastCheckin": "2014-10-24T18:37:50.498+0000",
            "name": "boogady",
            "owner": {
                "displayName": "Admin Owner",
                "key": "admin"
            },
            "releaseVer": null,
            "serviceLevel": "",
            "type": {
                "label": "system",
                "manifest": false
            },
            "username": "admin",
            "uuid": "7d479cd5-6ebc-4203-bf90-9a5ea50dfdb2"
        },
        "date": "2014-10-24T18:37:50.802+0000",
        "entitlements": [
            {
                "accountNumber": "12331131231",
                "attributes": {
                    "arch": "ALL",
                    "host_limited": "true",
                    "physical_only": "true",
                    "type": "MKT",
                    "variant": "ALL",
                    "version": "7.0",
                    "virt_limit": "unlimited"
                },
                "contractNumber": "5",
                "derivedProductAttributes": {},
                "derivedProductId": null,
                "derivedProductName": null,
                "derivedProvidedProducts": {},
                "endDate": "2015-10-16T00:00:00.000+0000",
                "orderNumber": "order-8675309",
                "productId": "awesomeos-virt-datacenter",
                "productName": "Awesome OS Virtual Datacenter",
                "providedProducts": {
                    "37060": "Awesome OS Server Bits"
                },
                "quantity": 1,
                "restrictedToUsername": null,
                "startDate": "2014-10-16T00:00:00.000+0000"
            }
        ],
        "status": {
            "compliantProducts": [
                "37060"
            ],
            "date": "2014-10-24T18:37:50.802+0000",
            "nonCompliantProducts": [],
            "partialStacks": [],
            "partiallyCompliantProducts": [],
            "reasons": [],
            "status": "valid"
        }
    },

    ...
]
```

Attribute filtering allows the client to customize the JSON representation of the compliance snapshot POJO.

```json
[
    {
        "consumer": {
            "lastCheckin": "2014-10-24T18:37:50.498+0000",
            "name": "boogady",
            "owner": {
                "key": "admin"
            },
            "uuid": "7d479cd5-6ebc-4203-bf90-9a5ea50dfdb2"
        },
        "date": "2014-10-24T18:37:50.802+0000",
        "status": {
            "status": "valid"
        }
    },

    ...
]
```

By default, reports utilize a minimized representation of a compliance snapshot to keep the overall size of
the response data down. If more data is required, attribute filtering can be used.

Use the following query parameters to make use of attribute filtering.

custom_results
: Enables/disables attribute filtering for the report (boolean).

include
: The name of an attribute to include. Can be a dotted path drilling down into the JSON structure.
: For example: _consumer.uuid_

exclude
: The name of an attribute to include. Can be a dotted path drilling down into the JSON structure.
: For example: _entitlements_

### Other notes
 * It is not possible to use both include and exclude in the same query
   * However you may use multiple of either filer type.
 * When the response is a list, a filter is applied to each member of the list
   * This is also applied on nested properties.
 * This works the same way as it does in candlepin.


### Some Examples

```console
# Enabling filtering without include/exclude parameters will result in the complete JSON representation.
$ curl -k "https://localhost:8443/gutterball/reports/consumer_status/run?consumer_uuid=5c2e62d3-9e01-40ca-aa83-c02a8635a9e7&custom_results=1"

```
```json
[
    {
      "consumer" : {
        "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7",
        "consumerState" : {
          "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7",
          "owner" : "admin",
          "created" : "2015-02-09T16:41:53.151+0000"
        },
        "name" : "boogady",
        "username" : "admin",
        "entitlementStatus" : "invalid",
        "serviceLevel" : "",
        "releaseVer" : null,
        "type" : {
          "label" : "system",
          "manifest" : false
        },
        "owner" : {
          "key" : "admin",
          "displayName" : "Admin Owner"
        },
        "entitlementCount" : 0,
        "lastCheckin" : "2015-02-10T13:36:44.104+0000",
        "facts" : {
          "lscpu.vendor_id" : "GenuineIntel",
          "dmi.chassis.power_supply_state" : "Safe",
          "dmi.bios.rom_size" : "2048 KB",
          "network.ipv4_address" : "127.0.0.1",
          "dmi.slot.type:slotbuswidth" : "x8",
          "net.interface.lo.ipv6_netmask.host" : "128",
          "cpu.topology_source" : "kernel /sys cpu sibling lists",
          "dmi.processor.l1_cache_handle" : "0x0702",
          "dmi.chassis.thermal_state" : "Safe",
          "lscpu.l1i_cache" : "32K",
          "distribution.version" : "20",
          "dmi.bios.runtime_size" : "64 KB",

          ...
        },
        "installedProducts" : [ {
          "productId" : "37060",
          "productName" : "Awesome OS Server Bits",
          "version" : "6.1",
          "arch" : "ALL",
          "status" : null,
          "startDate" : null,
          "endDate" : null
        } ],
        "guestIds" : [ ],
        "hypervisorId" : null,
        "environment" : null
      },
      "status" : {
        "status" : "valid",
        "reasons" : [ ],
        "nonCompliantProducts" : [ ],
        "compliantProducts" : [ "37060" ],
        "partiallyCompliantProducts" : [ ],
        "partialStacks" : [ ],
        "date" : "2015-02-10T13:36:47.074+0000"
      },
      "entitlements" : [ {
        "quantity" : 1,
        "startDate" : "2015-02-09T00:00:00.000+0000",
        "endDate" : "2016-02-09T00:00:00.000+0000",
        "productId" : "awesomeos-virt-4",
        "derivedProductId" : null,
        "productName" : "Awesome OS with up to 4 virtual guests",
        "derivedProductName" : null,
        "restrictedToUsername" : null,
        "contractNumber" : "4",
        "accountNumber" : "12331131231",
        "orderNumber" : "order-8675309",
        "attributes" : {
          "arch" : "ALL",
          "multi-entitlement" : "yes",
          "virt_limit" : "4",
          "type" : "MKT",
          "variant" : "ALL",
          "version" : "6.1"
        },
        "providedProducts" : {
          "37060" : "Awesome OS Server Bits"
        },
        "derivedProductAttributes" : { },
        "derivedProvidedProducts" : { }
      } ],
      "date" : "2015-02-10T13:36:47.074+0000"
    },

    ...

]
```

```console
# Include only the consumer UUID and all of the status information
$ curl -k "https://localhost:8443/gutterball/reports/consumer_status/run?custom_results=1&include=consumer.uuid&include=status.status"
```
```json
[
  {
    "consumer" : {
      "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7"
    },
    "status" : {
      "status" : "valid",
      "reasons" : [ ],
      "nonCompliantProducts" : [ ],
      "compliantProducts" : [ "37060" ],
      "partiallyCompliantProducts" : [ ],
      "partialStacks" : [ ],
      "date" : "2015-02-10T13:36:47.074+0000"
    }
  },

  ...
]
```

```console
# Exclude entitlement data only
$ curl -k "https://localhost:8443/gutterball/reports/consumer_status/run?custom_results=1&exclude=entitlements"
```
```json
[
    {
      "consumer" : {
        "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7",
        "consumerState" : {
          "uuid" : "5c2e62d3-9e01-40ca-aa83-c02a8635a9e7",
          "owner" : "admin",
          "created" : "2015-02-09T16:41:53.151+0000"
        },
        "name" : "boogady",
        "username" : "admin",
        "entitlementStatus" : "invalid",
        "serviceLevel" : "",
        "releaseVer" : null,
        "type" : {
          "label" : "system",
          "manifest" : false
        },
        "owner" : {
          "key" : "admin",
          "displayName" : "Admin Owner"
        },
        "entitlementCount" : 0,
        "lastCheckin" : "2015-02-10T13:36:44.104+0000",
        "facts" : {
          "lscpu.vendor_id" : "GenuineIntel",
          "dmi.chassis.power_supply_state" : "Safe",
          "dmi.bios.rom_size" : "2048 KB",
          "network.ipv4_address" : "127.0.0.1",
          "dmi.slot.type:slotbuswidth" : "x8",
          "net.interface.lo.ipv6_netmask.host" : "128",
          "cpu.topology_source" : "kernel /sys cpu sibling lists",
          "dmi.processor.l1_cache_handle" : "0x0702",
          "dmi.chassis.thermal_state" : "Safe",

          ...
        },
        "installedProducts" : [ {
          "productId" : "37060",
          "productName" : "Awesome OS Server Bits",
          "version" : "6.1",
          "arch" : "ALL",
          "status" : null,
          "startDate" : null,
          "endDate" : null
        } ],
        "guestIds" : [ ],
        "hypervisorId" : null,
        "environment" : null
      },
      "status" : {
        "status" : "valid",
        "reasons" : [ ],
        "nonCompliantProducts" : [ ],
        "compliantProducts" : [ "37060" ],
        "partiallyCompliantProducts" : [ ],
        "partialStacks" : [ ],
        "date" : "2015-02-10T13:36:47.074+0000"
      },
      "date" : "2015-02-10T13:36:47.074+0000"
    },

    ...
]


```

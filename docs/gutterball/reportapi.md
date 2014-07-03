---
categories: design
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

When a report is run, all specified parameters will be validated. GB will raise a BadParameterExcpetion which will be handled and return useful error data back to the client.

    {

      "displayMessage" : "'start_date' can not be used without and 'end_date'.",
      "requestUuid" : "e4654cdd-ba2d-436b-a28c-07b86f750344",
      "paramName" : "start_date",
      "paramValue" : "2014-06-06T15:06:16.943+0000"
    }

## API Example: Current Splice Report
The default report for Splice shows the status of active/inactive consumers for an Owner over a 24h period. Below are potential API calls that could be made to GB to execute the same report.

**GET /reports/consumer_status_report**

    {
      "key" : "consumer_status_report",
      "description" : "List the status of all consumers",
      "parameters" : [ {
        "name" : "satalite_server",
        "desc" : "The target satalite server",
        "mandatory" : false,
        "multiValued" : false
      }, {
        "name" : "end_date",
        "desc" : "The end date to filter on (used with start_date)",
        "mandatory" : false,
        "multiValued" : false
      }, {
        "name" : "status",
        "desc" : "The subscription status to filter on.",
        "mandatory" : false,
        "multiValued" : true
      }, {
        "name" : "hours",
        "desc" : "The number of hours filter on (used indepent of date range).",
        "mandatory" : false,
        "multiValued" : false
      }, {
        "name" : "owner",
        "desc" : "The Owner key(s) to filter on.",
        "mandatory" : false,
        "multiValued" : true
      }, {
        "name" : "start_date",
        "desc" : "The start date to filter on (used with end_date).",
        "mandatory" : false,
        "multiValued" : false
      }, {
        "name" : "life_cycle_state",
        "desc" : "The host life cycle state to filter on. [active, inactive]",
        "mandatory" : false,
        "multiValued" : true
      } ]
    }

**GET /reports/consumer_status_report/run?owner=ACME_Corporation&life_cycle_state=active&life_cycle_state=inactive&hours=24**

    {
      "results" : [ {
        "hostName" : "devbox.bugsquat.net",
        "systemId" : "112112-1221-23-3",
        "status" : "partial",
        "sateliteServer" : "dhcp-8-29-250.lab.eng.rdu2.redhat.com",
        "org" : "ACME_Corporation",
        "lastCheckIn" : "2014-06-06T14:17:33.862+0000",
        "lifeCycleDate" : "active"
      }, {
        "hostName" : "devbox3.bugsquat.net",
        "systemId" : "112112-1222-333",
        "status" : "partial",
        "sateliteServer" : "dhcp-8-29-250.lab.eng.rdu2.redhat.com",
        "org" : "ACME_Corporation",
        "lastCheckIn" : "2014-06-06T14:17:33.862+0000",
        "lifeCycleDate" : "inactive"
      } ]
    }


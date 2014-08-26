---
categories: Usage
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

    {

      "displayMessage" : "'start_date' can not be used without and 'end_date'.",
      "requestUuid" : "e4654cdd-ba2d-436b-a28c-07b86f750344",
      "paramName" : "start_date",
      "paramValue" : "2014-06-06T15:06:16.943+0000"
    }

## Current Reports

### Consumer Status Report

Lists the latest compliance status of consumers who have reported compliance during a specified time period.

**GET /reports/consumer_status_report**

Current details of the report parameters.

    {
      "key" : "consumer_status_report",
      "description" : "List the status of all consumers",
      "parameters" : [ {
        "mandatory" : false,
        "multiValued" : true,
        "description" : "Filters the results by the specified consumer UUID.",
        "name" : "consumer_uuid"
      }, {
        "mandatory" : false,
        "multiValued" : false,
        "description" : "The number of hours to filter on (used indepent of date range).",
        "name" : "hours"
      }, {
        "mandatory" : false,
        "multiValued" : true,
        "description" : "The Owner key(s) to filter on.",
        "name" : "owner"
      }, {
        "mandatory" : false,
        "multiValued" : true,
        "description" : "The subscription status to filter on.",
        "name" : "status"
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
      } ]
    }

**NOTES:**

1. Running the report with no start_date/end_date, or hours parameter, will not limit the results by date.
2. When specifying a date range, any consumer who last reported compliance outside of that range will not be included in the result.

**GET /reports/consumer_status_report/run?owner=ACME_Corporation&hours=24**

An example of running the report filtering by owner key and the latest in the last 24 hours.

      [
	    {
	      "_id" : "c1f8749f-6568-4159-83d4-a6c2d9da5a63",
	      "consumer" : {
	        "id" : "ff80808147f389160147f39120160000",
	        "uuid" : "c1f8749f-6568-4159-83d4-a6c2d9da5a63",
	        "name" : "boogady",
	        "username" : "admin",
	        "entitlementStatus" : "valid",
	        "serviceLevel" : "",
	        "releaseVer" : {
	          "releaseVer" : null
	        },
	        "idCert" : {
	          "id" : "ff80808147f389160147f39124950003",
	          "serial" : {
		    "id" : 9032979743114791317,
		    "revoked" : false,
		    "collected" : false,
		    "expiration" : "2030-08-20T13:18:00.486+0000",
		    "serial" : 9032979743114791317,
		    "created" : "2014-08-20T13:18:00.487+0000",
		    "updated" : "2014-08-20T13:18:00.487+0000"
	          },
	          "created" : "2014-08-20T13:18:01.365+0000",
	          "updated" : "2014-08-20T13:18:01.365+0000"
	        },
	        "type" : {
	          "id" : "1000",
	          "label" : "system",
	          "manifest" : false
	        },
	        "owner" : {
	          "id" : "ff80808147d9faa90147d9facadf0003",
	          "key" : "ACME_Corporation",
	          "displayName" : "ACME Corporation",
	          "href" : "/owners/ACME_Corporation"
	        },
	        "environment" : null,
	        "entitlementCount" : 1,
	        "facts" : {
	          "lscpu.vendor_id" : "GenuineIntel",
	          "dmi.chassis.power_supply_state" : "Safe",
	          "dmi.slot.type:slotbuswidth" : "x8",
	          "network.ipv4_address" : "127.0.0.1",
	          "dmi.bios.rom_size" : "2048 KB",
	          "net.interface.lo.ipv6_netmask.host" : "128",
	          "cpu.topology_source" : "kernel /sys cpu sibling lists",
	          "dmi.processor.l1_cache_handle" : "0x0702",
	          "dmi.chassis.thermal_state" : "Safe",
	          "lscpu.l1i_cache" : "32K",
	          "dmi.bios.runtime_size" : "64 KB",
	          "distribution.version" : "20",
	          "dmi.bios.bios_revision" : "0.0",
	          "dmi.memory.array_handle" : "0x1000",
	          "dmi.system.version" : "Not Specified",
	          "virt.is_guest" : "false",
	          "memory.swaptotal" : "6168572",
	          "dmi.memory.total_width" : "72 bit",
	          "net.interface.em1.ipv4_address" : "192.168.2.100",
	          "net.interface.lo.ipv6_address.host" : "::1",
	          "dmi.system.product_name" : "Precision WorkStation T5500",
	          "dmi.slot.slotlength" : "Long",
	          "system.certificate_version" : "3.2",
	          "dmi.memory.size" : "2048 MB",
	          "dmi.baseboard.version" : "A01",
	          "uname.version" : "#1 SMP Mon Jul 28 18:50:26 UTC 2014",
	          "dmi.bios.version" : "A09",
	          "lscpu.cpu(s)" : "4",
	          "dmi.chassis.version" : "Not Specified",
	          "dmi.processor.part_number" : "Not Specified",
	          "lscpu.numa_node0_cpu(s)" : "0-3",
	          "uname.nodename" : "boogady",
	          "dmi.chassis.security_status" : "None",
	          "dmi.processor.asset_tag" : "Not Specified",
	          "dmi.memory.speed" : "1333 MHz (0.8ns)",
	          "net.interface.em1.ipv6_netmask.link" : "64",
	          "net.interface.tun0.mac_address" : "none",
	          "net.interface.em1.ipv4_netmask" : "24",
	          "dmi.processor.l2_cache_handle" : "0x0703",
	          "dmi.system.wake-up_type" : "Power Switch",
	          "net.interface.virbr0.mac_address" : "c2:08:ca:90:51:b1",
	          "dmi.memory.assettag" : "02111461",
	          "net.interface.tun0.ipv4_netmask" : "24",
	          "dmi.chassis.asset_tag" : "",
	          "memory.memtotal" : "12296876",
	          "lscpu.on-line_cpu(s)_list" : "0-3",
	          "dmi.memory.form_factor" : "DIMM",
	          "net.interface.em1.ipv6_address.link" : "fe80::16fe:b5ff:fee4:bd2e",
	          "dmi.processor.socket_designation" : "CPU2",
	          "lscpu.numa_node(s)" : "1",
	          "net.interface.em1.mac_address" : "14:fe:b5:e4:bd:2e",
	          "lscpu.socket(s)" : "1",
	          "dmi.memory.data_width" : "64 bit",
	          "dmi.system.status" : "No errors detected",
	          "lscpu.virtualization" : "VT-x",
	          "net.interface.lo.ipv4_address" : "127.0.0.1",
	          "dmi.baseboard.product_name" : "0CRH6C",
	          "lscpu.stepping" : "2",
	          "net.interface.virbr0.ipv4_address" : "192.168.122.1",
	          "dmi.memory.manufacturer" : "80CE80B380CE",
	          "lscpu.cpu_family" : "6",
	          "dmi.memory.maximum_capacity" : "96 GB",
	          "net.interface.lo.ipv4_netmask" : "8",
	          "lscpu.cpu_op-mode(s)" : "32-bit, 64-bit",
	          "dmi.processor.type" : "Central Processor",
	          "lscpu.byte_order" : "Little Endian",
	          "dmi.memory.type" : "",
	          "network.hostname" : "boogady",
	          "dmi.memory.part_number" : "M393B5773CH0-YH9",
	          "lscpu.core(s)_per_socket" : "4",
	          "dmi.memory.serial_number" : "8367C865",
	          "network.ipv6_address" : "::1",
	          "dmi.chassis.manufacturer" : "Dell Inc.",
	          "dmi.baseboard.manufacturer" : "Dell Inc.",
	          "dmi.connector.external_reference_designator" : "Not Specified",
	          "lscpu.cpu_mhz" : "1595.990",
	          "dmi.system.uuid" : "44454c4c-4400-1031-8030-b6c04f395231",
	          "lscpu.model" : "44",
	          "dmi.memory.error_correction_type" : "Multi-bit ECC",
	          "dmi.processor.upgrade" : "Socket LGA771",
	          "lscpu.model_name" : "Intel(R) Xeon(R) CPU           E5603  @ 1.60GHz",
	          "dmi.processor.family" : "Xeon",
	          "lscpu.bogomips" : "3191.98",
	          "net.interface.virbr0.ipv4_broadcast" : "192.168.122.255",
	          "cpu.thread(s)_per_core" : "1",
	          "net.interface.p1p1.mac_address" : "00:10:18:a1:93:5b",
	          "dmi.system.sku_number" : "Not Specified",
	          "lscpu.l3_cache" : "4096K",
	          "dmi.processor.serial_number" : "Not Specified",
	          "dmi.connector.internal_reference_designator" : "LINE-IN",
	          "dmi.memory.location" : "System Board Or Motherboard",
	          "distribution.id" : "Heisenbug",
	          "dmi.bios.vendor" : "Dell Inc.",
	          "dmi.chassis.type" : "Tower",
	          "dmi.slot.designation" : "SLOT1",
	          "dmi.slot.type:slottype" : "PCI Express",
	          "cpu.cpu(s)" : "4",
	          "cpu.core(s)_per_socket" : "4",
	          "lscpu.l1d_cache" : "32K",
	          "dmi.chassis.serial_number" : "6D109R1",
	          "dmi.slot.slotid" : "1",
	          "virt.host_type" : "Not Applicable",
	          "dmi.memory.error_information_handle" : "No Error",
	          "dmi.system.manufacturer" : "Dell Inc.",
	          "dmi.system.serial_number" : "6D109R1",
	          "cpu.cpu_socket(s)" : "1",
	          "net.interface.virbr0.ipv4_netmask" : "24",
	          "lscpu.thread(s)_per_core" : "1",
	          "dmi.bios.relase_date" : "04/20/2011",
	          "dmi.chassis.boot-up_state" : "Warning",
	          "net.interface.tun0.ipv4_address" : "10.3.113.158",
	          "dmi.connector.port_type" : "Audio Port",
	          "lscpu.architecture" : "x86_64",
	          "dmi.memory.use" : "System Memory",
	          "dmi.connector.internal_connector_type" : "None",
	          "dmi.processor.version" : "Not Specified",
	          "dmi.memory.bank_locator" : "Not Specified",
	          "lscpu.l2_cache" : "256K",
	          "net.interface.em1.ipv4_broadcast" : "192.168.2.255",
	          "net.interface.lo.ipv4_broadcast" : "Unknown",
	          "dmi.system.family" : "Not Specified",
	          "dmi.processor.voltage" : " ",
	          "dmi.processor.l3_cache_handle" : "0x0705",
	          "distribution.name" : "Fedora",
	          "dmi.baseboard.serial_number" : "..CN1374014I00DC.",
	          "uname.sysname" : "Linux",
	          "uname.release" : "3.15.7-200.fc20.x86_64",
	          "dmi.connector.external_connector_type" : "Mini Jack (headphones)",
	          "dmi.processor.status" : "Populated:No",
	          "uname.machine" : "x86_64",
	          "net.interface.tun0.ipv4_broadcast" : "10.3.113.255",
	          "dmi.memory.locator" : "DIMM 4",
	          "dmi.bios.address" : "0xf0000",
	          "dmi.slot.current_usage" : "In Use",
	          "dmi.chassis.lock" : "Not Present"
	        },
	        "lastCheckin" : "2014-08-26T09:05:25.730+0000",
	        "installedProducts" : [ {
	          "id" : "ff80808147f389160147f39120280001",
	          "productId" : "27060",
	          "productName" : "Awesome OS Workstation Bits",
	          "version" : "6.1",
	          "arch" : "ALL",
	          "status" : null,
	          "startDate" : null,
	          "endDate" : null,
	          "created" : "2014-08-20T13:18:00.232+0000",
	          "updated" : "2014-08-20T13:18:00.232+0000"
	        } ],
	        "canActivate" : false,
	        "guestIds" : [ ],
	        "capabilities" : [ ],
	        "hypervisorId" : null,
	        "autoheal" : true,
	        "href" : "/consumers/c1f8749f-6568-4159-83d4-a6c2d9da5a63",
	        "created" : "2014-08-20T13:18:00.214+0000",
	        "updated" : "2014-08-26T09:05:25.730+0000"
	      },
	      "status" : {
	        "date" : "2014-08-26T09:05:25.918+0000",
	        "compliantUntil" : null,
	        "nonCompliantProducts" : [ ],
	        "compliantProducts" : {
	          "27060" : [ {
		    "id" : "ff80808147f389160147f3918920000b",
		    "consumer" : null,
		    "pool" : {
		      "id" : "ff80808147d9faa90147d9fb50141816",
		      "productId" : "awesomeos-workstation-basic",
		      "productName" : "Awesome OS Workstation Basic",
		      "href" : "/pools/ff80808147d9faa90147d9fb50141816"
		    },
		    "certificates" : [ ],
		    "quantity" : 1,
		    "startDate" : "2014-08-15T00:00:00.000+0000",
		    "endDate" : "2015-08-15T00:00:00.000+0000",
		    "href" : "/entitlements/ff80808147f389160147f3918920000b",
		    "created" : "2014-08-20T13:18:27.104+0000",
		    "updated" : "2014-08-20T13:18:27.104+0000"
	          } ]
	        },
	        "partiallyCompliantProducts" : { },
	        "partialStacks" : { },
	        "reasons" : [ ],
	        "compliant" : true,
	        "status" : "valid"
	      }
	    }
      ]

Each result entry contains two key bits of information: **consumer** and **status**. Combined, they represent the state of the consumer and its status at the time compliance was reported by candlepin.


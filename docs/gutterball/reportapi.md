---
categories: Developers
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
      "displayMessage" : "on_date: Invalid date string. Expected format: yyyy-MM-dd'T'HH:mm:ss.SSSZ",
      "requestUuid" : "6fbd6cc8-1838-43f7-a4d8-7a759e47aa02"
    }

## Current Reports

### Consumer Status Report

Lists the latest compliance status of consumers who have reported compliance during a specified time period.

**GET /reports/consumer_status_report**

Current details of the report parameters.

    [
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
          "description" : "The date to filter on. Defaults to NOW.",
          "name" : "on_date"
        } ]
      }
    ]

**NOTES:**

1. Running the report with no paramters will return all compliance status records for all reported consumers.
2. When specifying the **on_date** paramter, results will be limited to compliance status records that were last reported before or on that date.
3. Generally **status** values from candlepin will be one of: valid, partial, invalid

**GET /reports/consumer_status_report/run?owner=ACME_Corporation**

An example of running the report filtering by owner key.

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
                    "cpu.thread(s)_per_core": "1",
                    "cpu.topology_source": "kernel /sys cpu sibling lists",
                    "distribution.id": "Heisenbug",
                    "distribution.name": "Fedora",
                    "distribution.version": "20",
                    "dmi.baseboard.manufacturer": "Dell Inc.",
                    "dmi.baseboard.product_name": "0CRH6C",
                    "dmi.baseboard.serial_number": "..CN1374014I00DC.",
                    "dmi.baseboard.version": "A01",
                    "dmi.bios.address": "0xf0000",
                    "dmi.bios.bios_revision": "0.0",
                    "dmi.bios.relase_date": "04/20/2011",
                    "dmi.bios.rom_size": "2048 KB",
                    "dmi.bios.runtime_size": "64 KB",
                    "dmi.bios.vendor": "Dell Inc.",
                    "dmi.bios.version": "A09",
                    "dmi.chassis.asset_tag": "",
                    "dmi.chassis.boot-up_state": "Warning",
                    "dmi.chassis.lock": "Not Present",
                    "dmi.chassis.manufacturer": "Dell Inc.",
                    "dmi.chassis.power_supply_state": "Safe",
                    "dmi.chassis.security_status": "None",
                    "dmi.chassis.serial_number": "6D109R1",
                    "dmi.chassis.thermal_state": "Safe",
                    "dmi.chassis.type": "Tower",
                    "dmi.chassis.version": "Not Specified",
                    "dmi.connector.external_connector_type": "Mini Jack (headphones)",
                    "dmi.connector.external_reference_designator": "Not Specified",
                    "dmi.connector.internal_connector_type": "None",
                    "dmi.connector.internal_reference_designator": "LINE-IN",
                    "dmi.connector.port_type": "Audio Port",
                    "dmi.memory.array_handle": "0x1000",
                    "dmi.memory.assettag": "02111461",
                    "dmi.memory.bank_locator": "Not Specified",
                    "dmi.memory.data_width": "64 bit",
                    "dmi.memory.error_correction_type": "Multi-bit ECC",
                    "dmi.memory.error_information_handle": "No Error",
                    "dmi.memory.form_factor": "DIMM",
                    "dmi.memory.location": "System Board Or Motherboard",
                    "dmi.memory.locator": "DIMM 4",
                    "dmi.memory.manufacturer": "80CE80B380CE",
                    "dmi.memory.maximum_capacity": "96 GB",
                    "dmi.memory.part_number": "M393B5773CH0-YH9",
                    "dmi.memory.serial_number": "8367C865",
                    "dmi.memory.size": "2048 MB",
                    "dmi.memory.speed": "1333 MHz (0.8ns)",
                    "dmi.memory.total_width": "72 bit",
                    "dmi.memory.type": "",
                    "dmi.memory.use": "System Memory",
                    "dmi.processor.asset_tag": "Not Specified",
                    "dmi.processor.family": "Xeon",
                    "dmi.processor.l1_cache_handle": "0x0702",
                    "dmi.processor.l2_cache_handle": "0x0703",
                    "dmi.processor.l3_cache_handle": "0x0705",
                    "dmi.processor.part_number": "Not Specified",
                    "dmi.processor.serial_number": "Not Specified",
                    "dmi.processor.socket_designation": "CPU2",
                    "dmi.processor.status": "Populated:No",
                    "dmi.processor.type": "Central Processor",
                    "dmi.processor.upgrade": "Socket LGA771",
                    "dmi.processor.version": "Not Specified",
                    "dmi.processor.voltage": " ",
                    "dmi.slot.current_usage": "In Use",
                    "dmi.slot.designation": "SLOT1",
                    "dmi.slot.slotid": "1",
                    "dmi.slot.slotlength": "Long",
                    "dmi.slot.type:slotbuswidth": "x8",
                    "dmi.slot.type:slottype": "PCI Express",
                    "dmi.system.family": "Not Specified",
                    "dmi.system.manufacturer": "Dell Inc.",
                    "dmi.system.product_name": "Precision WorkStation T5500",
                    "dmi.system.serial_number": "6D109R1",
                    "dmi.system.sku_number": "Not Specified",
                    "dmi.system.status": "No errors detected",
                    "dmi.system.uuid": "44454c4c-4400-1031-8030-b6c04f395231",
                    "dmi.system.version": "Not Specified",
                    "dmi.system.wake-up_type": "Power Switch",
                    "lscpu.architecture": "x86_64",
                    "lscpu.bogomips": "3192.05",
                    "lscpu.byte_order": "Little Endian",
                    "lscpu.core(s)_per_socket": "4",
                    "lscpu.cpu(s)": "4",
                    "lscpu.cpu_family": "6",
                    "lscpu.cpu_mhz": "1596.027",
                    "lscpu.cpu_op-mode(s)": "32-bit, 64-bit",
                    "lscpu.l1d_cache": "32K",
                    "lscpu.l1i_cache": "32K",
                    "lscpu.l2_cache": "256K",
                    "lscpu.l3_cache": "4096K",
                    "lscpu.model": "44",
                    "lscpu.model_name": "Intel(R) Xeon(R) CPU           E5603  @ 1.60GHz",
                    "lscpu.numa_node(s)": "1",
                    "lscpu.numa_node0_cpu(s)": "0-3",
                    "lscpu.on-line_cpu(s)_list": "0-3",
                    "lscpu.socket(s)": "1",
                    "lscpu.stepping": "2",
                    "lscpu.thread(s)_per_core": "1",
                    "lscpu.vendor_id": "GenuineIntel",
                    "lscpu.virtualization": "VT-x",
                    "memory.memtotal": "12296840",
                    "memory.swaptotal": "6168572",
                    "net.interface.em1.ipv4_address": "192.168.2.100",
                    "net.interface.em1.ipv4_broadcast": "192.168.2.255",
                    "net.interface.em1.ipv4_netmask": "24",
                    "net.interface.em1.ipv6_address.link": "fe80::16fe:b5ff:fee4:bd2e",
                    "net.interface.em1.ipv6_netmask.link": "64",
                    "net.interface.em1.mac_address": "14:fe:b5:e4:bd:2e",
                    "net.interface.lo.ipv4_address": "127.0.0.1",
                    "net.interface.lo.ipv4_broadcast": "Unknown",
                    "net.interface.lo.ipv4_netmask": "8",
                    "net.interface.lo.ipv6_address.host": "::1",
                    "net.interface.lo.ipv6_netmask.host": "128",
                    "net.interface.p1p1.mac_address": "00:10:18:a1:93:5b",
                    "net.interface.tun0.ipv4_address": "10.3.113.152",
                    "net.interface.tun0.ipv4_broadcast": "10.3.113.255",
                    "net.interface.tun0.ipv4_netmask": "24",
                    "net.interface.tun0.mac_address": "none",
                    "net.interface.virbr0-nic.mac_address": "52:54:00:f1:78:9f",
                    "net.interface.virbr0-nic.permanent_mac_address": "",
                    "net.interface.virbr0.ipv4_address": "192.168.122.1",
                    "net.interface.virbr0.ipv4_broadcast": "192.168.122.255",
                    "net.interface.virbr0.ipv4_netmask": "24",
                    "net.interface.virbr0.mac_address": "52:54:00:f1:78:9f",
                    "network.hostname": "boogady",
                    "network.ipv4_address": "127.0.0.1",
                    "network.ipv6_address": "::1",
                    "system.certificate_version": "3.2",
                    "uname.machine": "x86_64",
                    "uname.nodename": "boogady",
                    "uname.release": "3.16.6-200.fc20.x86_64",
                    "uname.sysname": "Linux",
                    "uname.version": "#1 SMP Wed Oct 15 13:06:51 UTC 2014",
                    "virt.host_type": "Not Applicable",
                    "virt.is_guest": "false"
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
        }
    ]


Each result entry contains three key bits of information: **consumer**, **entitlements**, and **status**. Combined, they represent the
state of the consumer and its status at the time compliance was reported by candlepin.


### Consumer Trend Report

Lists ALL compliance snapshots for consumers who have reported compliance status in the specified time period.

**GET /reports/consumer_trend_report**

Current details of the report parameters.

    {
      "key" : "consumer_trend_report",
      "description" : "Lists the status of each consumer over a date range",
      "parameters" : [ {
        "mandatory" : false,
        "multiValued" : true,
        "description" : "Filters the results by the specified consumer UUID.",
        "name" : "consumer_uuid"
      }, {
        "mandatory" : false,
        "multiValued" : true,
        "description" : "The Owner key(s) to filter on.",
        "name" : "owner"
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
      } ]
    }

**NOTES:**

1. Report result is a map of consumer_uuid to list of compliance snapshots.
2. Parameters allow limiting results to specific owners and consumers.

**GET /reports/consumer_trend_report/run?owner=admin&hours=24**

An example of running the report filtering by owner and for the last 24 hours.

    {
      "f2ac42dc-e4c4-4a9d-8181-eb7f995b0b9f" : [ {
        "consumer" : {
          "uuid" : "f2ac42dc-e4c4-4a9d-8181-eb7f995b0b9f",
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
          "lastCheckin" : null,
          "facts" : {
            "lscpu.vendor_id" : "GenuineIntel",
            "dmi.chassis.power_supply_state" : "Safe",
            "network.ipv4_address" : "127.0.0.1",
            "dmi.bios.rom_size" : "2048 KB",
            "dmi.slot.type:slotbuswidth" : "x8",
            "net.interface.lo.ipv6_netmask.host" : "128",
            "cpu.topology_source" : "kernel /sys cpu sibling lists",
            "dmi.processor.l1_cache_handle" : "0x0702",
            "dmi.chassis.thermal_state" : "Safe",
            "lscpu.l1i_cache" : "32K",
            "distribution.version" : "20",
            "dmi.bios.runtime_size" : "64 KB",
            "dmi.bios.bios_revision" : "0.0",
            "dmi.memory.array_handle" : "0x1000",
            "dmi.system.version" : "Not Specified",
            "virt.is_guest" : "false",
            "memory.swaptotal" : "6168572",
            "dmi.memory.total_width" : "72 bit",
            "net.interface.lo.ipv6_address.host" : "::1",
            "net.interface.em1.ipv4_address" : "192.168.2.100",
            "dmi.system.product_name" : "Precision WorkStation T5500",
            "dmi.slot.slotlength" : "Long",
            "system.certificate_version" : "3.2",
            "dmi.memory.size" : "2048 MB",
            "dmi.baseboard.version" : "A01",
            "uname.version" : "#1 SMP Wed Oct 15 13:06:51 UTC 2014",
            "dmi.bios.version" : "A09",
            "dmi.chassis.version" : "Not Specified",
            "lscpu.cpu(s)" : "4",
            "dmi.processor.part_number" : "Not Specified",
            "lscpu.numa_node0_cpu(s)" : "0-3",
            "uname.nodename" : "boogady",
            "dmi.chassis.security_status" : "None",
            "dmi.memory.speed" : "1333 MHz (0.8ns)",
            "dmi.processor.asset_tag" : "Not Specified",
            "net.interface.tun0.mac_address" : "none",
            "net.interface.em1.ipv6_netmask.link" : "64",
            "net.interface.em1.ipv4_netmask" : "24",
            "dmi.processor.l2_cache_handle" : "0x0703",
            "dmi.system.wake-up_type" : "Power Switch",
            "net.interface.virbr0.mac_address" : "52:54:00:f1:78:9f",
            "dmi.memory.assettag" : "02111461",
            "net.interface.tun0.ipv4_netmask" : "24",
            "dmi.chassis.asset_tag" : "",
            "memory.memtotal" : "12296840",
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
            "dmi.memory.maximum_capacity" : "96 GB",
            "dmi.memory.manufacturer" : "80CE80B380CE",
            "lscpu.cpu_family" : "6",
            "net.interface.lo.ipv4_netmask" : "8",
            "dmi.processor.type" : "Central Processor",
            "lscpu.byte_order" : "Little Endian",
            "lscpu.cpu_op-mode(s)" : "32-bit, 64-bit",
            "dmi.memory.type" : "",
            "network.hostname" : "boogady",
            "dmi.memory.part_number" : "M393B5773CH0-YH9",
            "lscpu.core(s)_per_socket" : "4",
            "dmi.memory.serial_number" : "8367C865",
            "network.ipv6_address" : "::1",
            "dmi.chassis.manufacturer" : "Dell Inc.",
            "dmi.connector.external_reference_designator" : "Not Specified",
            "dmi.baseboard.manufacturer" : "Dell Inc.",
            "lscpu.cpu_mhz" : "1596.027",
            "dmi.system.uuid" : "44454c4c-4400-1031-8030-b6c04f395231",
            "lscpu.model" : "44",
            "dmi.memory.error_correction_type" : "Multi-bit ECC",
            "dmi.processor.upgrade" : "Socket LGA771",
            "lscpu.model_name" : "Intel(R) Xeon(R) CPU           E5603  @ 1.60GHz",
            "dmi.processor.family" : "Xeon",
            "lscpu.bogomips" : "3192.05",
            "net.interface.virbr0-nic.mac_address" : "52:54:00:f1:78:9f",
            "net.interface.virbr0.ipv4_broadcast" : "192.168.122.255",
            "cpu.thread(s)_per_core" : "1",
            "net.interface.p1p1.mac_address" : "00:10:18:a1:93:5b",
            "dmi.system.sku_number" : "Not Specified",
            "lscpu.l3_cache" : "4096K",
            "dmi.processor.serial_number" : "Not Specified",
            "dmi.connector.internal_reference_designator" : "LINE-IN",
            "net.interface.virbr0-nic.permanent_mac_address" : "",
            "dmi.memory.location" : "System Board Or Motherboard",
            "distribution.id" : "Heisenbug",
            "dmi.bios.vendor" : "Dell Inc.",
            "dmi.chassis.type" : "Tower",
            "dmi.slot.designation" : "SLOT1",
            "dmi.slot.type:slottype" : "PCI Express",
            "cpu.cpu(s)" : "4",
            "cpu.core(s)_per_socket" : "4",
            "dmi.chassis.serial_number" : "6D109R1",
            "lscpu.l1d_cache" : "32K",
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
            "net.interface.tun0.ipv4_address" : "10.3.113.152",
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
            "uname.release" : "3.16.6-200.fc20.x86_64",
            "dmi.connector.external_connector_type" : "Mini Jack (headphones)",
            "dmi.processor.status" : "Populated:No",
            "uname.machine" : "x86_64",
            "net.interface.tun0.ipv4_broadcast" : "10.3.113.255",
            "dmi.memory.locator" : "DIMM 4",
            "dmi.bios.address" : "0xf0000",
            "dmi.slot.current_usage" : "In Use",
            "dmi.chassis.lock" : "Not Present"
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
          "status" : "invalid",
          "reasons" : [ {
            "key" : "NOTCOVERED",
            "message" : "Not supported by a valid subscription.",
            "attributes" : {
              "product_id" : "37060",
              "name" : "Awesome OS Server Bits"
            }
          } ],
          "nonCompliantProducts" : [ "37060" ],
          "compliantProducts" : [ ],
          "partiallyCompliantProducts" : [ ],
          "partialStacks" : [ ],
          "date" : "2014-10-24T19:18:35.143+0000"
        },
        "entitlements" : [ ],
        "date" : "2014-10-24T19:18:35.143+0000"
      }, {
        "consumer" : {
          "uuid" : "f2ac42dc-e4c4-4a9d-8181-eb7f995b0b9f",
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
          "lastCheckin" : null,
          "facts" : {
            "lscpu.vendor_id" : "GenuineIntel",
            "dmi.chassis.power_supply_state" : "Safe",
            "network.ipv4_address" : "127.0.0.1",
            "dmi.bios.rom_size" : "2048 KB",
            "dmi.slot.type:slotbuswidth" : "x8",
            "net.interface.lo.ipv6_netmask.host" : "128",
            "cpu.topology_source" : "kernel /sys cpu sibling lists",
            "dmi.processor.l1_cache_handle" : "0x0702",
            "dmi.chassis.thermal_state" : "Safe",
            "lscpu.l1i_cache" : "32K",
            "distribution.version" : "20",
            "dmi.bios.runtime_size" : "64 KB",
            "dmi.bios.bios_revision" : "0.0",
            "dmi.memory.array_handle" : "0x1000",
            "dmi.system.version" : "Not Specified",
            "virt.is_guest" : "false",
            "memory.swaptotal" : "6168572",
            "dmi.memory.total_width" : "72 bit",
            "net.interface.lo.ipv6_address.host" : "::1",
            "net.interface.em1.ipv4_address" : "192.168.2.100",
            "dmi.system.product_name" : "Precision WorkStation T5500",
            "dmi.slot.slotlength" : "Long",
            "system.certificate_version" : "3.2",
            "dmi.memory.size" : "2048 MB",
            "dmi.baseboard.version" : "A01",
            "uname.version" : "#1 SMP Wed Oct 15 13:06:51 UTC 2014",
            "dmi.bios.version" : "A09",
            "dmi.chassis.version" : "Not Specified",
            "lscpu.cpu(s)" : "4",
            "dmi.processor.part_number" : "Not Specified",
            "lscpu.numa_node0_cpu(s)" : "0-3",
            "uname.nodename" : "boogady",
            "dmi.chassis.security_status" : "None",
            "dmi.memory.speed" : "1333 MHz (0.8ns)",
            "dmi.processor.asset_tag" : "Not Specified",
            "net.interface.tun0.mac_address" : "none",
            "net.interface.em1.ipv6_netmask.link" : "64",
            "net.interface.em1.ipv4_netmask" : "24",
            "dmi.processor.l2_cache_handle" : "0x0703",
            "dmi.system.wake-up_type" : "Power Switch",
            "net.interface.virbr0.mac_address" : "52:54:00:f1:78:9f",
            "dmi.memory.assettag" : "02111461",
            "net.interface.tun0.ipv4_netmask" : "24",
            "dmi.chassis.asset_tag" : "",
            "memory.memtotal" : "12296840",
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
            "dmi.memory.maximum_capacity" : "96 GB",
            "dmi.memory.manufacturer" : "80CE80B380CE",
            "lscpu.cpu_family" : "6",
            "net.interface.lo.ipv4_netmask" : "8",
            "dmi.processor.type" : "Central Processor",
            "lscpu.byte_order" : "Little Endian",
            "lscpu.cpu_op-mode(s)" : "32-bit, 64-bit",
            "dmi.memory.type" : "",
            "network.hostname" : "boogady",
            "dmi.memory.part_number" : "M393B5773CH0-YH9",
            "lscpu.core(s)_per_socket" : "4",
            "dmi.memory.serial_number" : "8367C865",
            "network.ipv6_address" : "::1",
            "dmi.chassis.manufacturer" : "Dell Inc.",
            "dmi.connector.external_reference_designator" : "Not Specified",
            "dmi.baseboard.manufacturer" : "Dell Inc.",
            "lscpu.cpu_mhz" : "1596.027",
            "dmi.system.uuid" : "44454c4c-4400-1031-8030-b6c04f395231",
            "lscpu.model" : "44",
            "dmi.memory.error_correction_type" : "Multi-bit ECC",
            "dmi.processor.upgrade" : "Socket LGA771",
            "lscpu.model_name" : "Intel(R) Xeon(R) CPU           E5603  @ 1.60GHz",
            "dmi.processor.family" : "Xeon",
            "lscpu.bogomips" : "3192.05",
            "net.interface.virbr0-nic.mac_address" : "52:54:00:f1:78:9f",
            "net.interface.virbr0.ipv4_broadcast" : "192.168.122.255",
            "cpu.thread(s)_per_core" : "1",
            "net.interface.p1p1.mac_address" : "00:10:18:a1:93:5b",
            "dmi.system.sku_number" : "Not Specified",
            "lscpu.l3_cache" : "4096K",
            "dmi.processor.serial_number" : "Not Specified",
            "dmi.connector.internal_reference_designator" : "LINE-IN",
            "net.interface.virbr0-nic.permanent_mac_address" : "",
            "dmi.memory.location" : "System Board Or Motherboard",
            "distribution.id" : "Heisenbug",
            "dmi.bios.vendor" : "Dell Inc.",
            "dmi.chassis.type" : "Tower",
            "dmi.slot.designation" : "SLOT1",
            "dmi.slot.type:slottype" : "PCI Express",
            "cpu.cpu(s)" : "4",
            "cpu.core(s)_per_socket" : "4",
            "dmi.chassis.serial_number" : "6D109R1",
            "lscpu.l1d_cache" : "32K",
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
            "net.interface.tun0.ipv4_address" : "10.3.113.152",
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
            "uname.release" : "3.16.6-200.fc20.x86_64",
            "dmi.connector.external_connector_type" : "Mini Jack (headphones)",
            "dmi.processor.status" : "Populated:No",
            "uname.machine" : "x86_64",
            "net.interface.tun0.ipv4_broadcast" : "10.3.113.255",
            "dmi.memory.locator" : "DIMM 4",
            "dmi.bios.address" : "0xf0000",
            "dmi.slot.current_usage" : "In Use",
            "dmi.chassis.lock" : "Not Present"
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
          "status" : "invalid",
          "reasons" : [ {
            "key" : "NOTCOVERED",
            "message" : "Not supported by a valid subscription.",
            "attributes" : {
              "product_id" : "37060",
              "name" : "Awesome OS Server Bits"
            }
          } ],
          "nonCompliantProducts" : [ "37060" ],
          "compliantProducts" : [ ],
          "partiallyCompliantProducts" : [ ],
          "partialStacks" : [ ],
          "date" : "2014-10-24T19:18:33.689+0000"
        },
        "entitlements" : [ ],
        "date" : "2014-10-24T19:18:33.689+0000"
      } ]
    }


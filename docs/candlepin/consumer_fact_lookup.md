---
layout: default
categories: usage
title: Lookup Consumers By Facts
---
{% include toc.md %}

# Building a Consumer Query Using Facts

## Overview
Candlepin allows consumers to be listed filtered by facts in much the same way as pool filtering.
The goal for this feature is to provide support for features in any candlepin deployment that were previously limited to SAM and Satellite.
For instance, RHEV clusters may be built up of both registered and unregistered hypervisors.
In order to avoid creating a hypervisor consumer representation of systems that are already registered, we need to be able to look for registered consumers with certain key-value fact combinations.
Because we know that RHEV generates hypervisor ids based on dmi uuid and mac address, we already have all the information we need at our disposal.

## Usage and Examples
Currently we allow listing consumers in two places:
/consumers
and
/owners/{owner_key}/consumers
At this point, both api points support any combination of search parameters.

### List All Virtual Systems
To list all virtual consumers in org 'foo':

* Note that the key is case sensitive, and value is not

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/consumers?owner=foo&fact=virt.is_guest:true"
```

### Filtering with an OR
To list all consumers in my org that are running on either ESX or kvm hypervisors, one can add two key:value fact pairs with the same key to represent an OR 

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/consumers?owner=foo&fact=virt.host_type:ESX&fact=virt.host_type=kvm"
```

### RHEV Example
To continue the example from the summary, to check if a rhev hypervisor exists (given its hypervisor id) we can build a query.
RHEV hypervisor uuids are build with this command:

```console
/bin/echo -e `/bin/bash -c  /usr/sbin/dmidecode|/bin/awk ' /UUID/{ print $2; } ' | /usr/bin/tr '\n' '_' && 
   cat /sys/class/net/*/address | /bin/grep -v '00:00:00:00' | /bin/sort -u | /usr/bin/head --lines=1`
```

For this example we can use the hypervisor uuid "E34EDC99-388C-4E25-9052-8A0114E20FE5_52:54:00:12:3c:aa".

We need to find a system with dmi.uuid matching "E34EDC99-388C-4E25-9052-8A0114E20FE5" and a mac address matching "52:54:00:12:3c:aa".

However, mac addresses in consumer facts are named based on their interface, so we cannot look for a specific key

Example:

```console
# subscription-manager facts --list | grep mac_address
net.interface.em1.mac_address: 90:b1:1c:90:25:b1
net.interface.virbr2-nic.mac_address: 52:54:00:24:3b:aa
net.interface.virbr2-nic.permanent_mac_address: Unknown
net.interface.virbr2.mac_address: 52:54:00:24:3b:aa
```

Using the net.interface.foo.mac_address form, we can use wildcards!
For values like mac addresses, keep in mind that fact=key:value is split on the first, and only the first colon.

```console
curl -k -u admin:admin "https://localhost:8443/candlepin/consumers?owner=foo&fact=dmi.system.uuid:E34EDC99-388C-4E25-9052-8A0114E20FE5&fact=net.interface.*.mac_address:52:54:00:12:3c:aa"
```

## Consolidated Information

* Key is case sensitive, however value is not
* Wildcard \* may be used as many times as needed in any key and/or value
  * Ex: ```fact=net.interface.*.mac_address:52:54:00:12:3c:aa may be shortened to fact=*mac_addr*:52:54:00:12:3c:aa```
* KeyValue parameters are split on ONLY the first colon
* Using the same key with different values represents OR

---
categories: design
title: Compliance Snapshots
---
{% include toc.md %}

# Compliance Snapshots

GB: GutterBall

To support reporting in general as well as usage based subscriptions, there is a need to create state and compliance snapshots of the Consumers in Candlepin. Ideally, this will occur in a way that keeps the acquisition, dissemination, and storage of the data as separate from the existing Candlepin tasks as possible. We already support asynchronous events, so this would be the best way to get this information to the tool that can process and store the data.

For every state change a consumer experiences [listed below] the JSON representation of the consumer will be included in the event. This JSON currently contains the certificates for the Consumer or any Entitlements. We should investigate whether we should create a new class of object mapper that defines which fields are needed in the JSON for the events. The EventFactory would need to be modified include the mapper, if needed. The event objects will need to be modified to include an identifier for the Candlepin server from which it originated.

We will use qpid to receive events from Candlepin. For a Satellite install we'll use the qpid installed by Pulp. If it is not a  Satellite install, we'll create a message  bus as part of the GutterBall install. We'll use the qpid JMS library to retrieve the messages from the bus.

An assumption is made that each event received by GB will cause a calculation and storage of the compliance status of the conusumer. This will create a historical snapshot for that point in time.

We will also create a REST query that will allow a snapshot event to be sent on demand for an individual consumer. This will be used in scenarios where events may have been mistakenly dropped. It will eliminate the need to change somehting in Candlepin just to spawn the event.

As per Satellite -> Candlepin today, Satellite UI enforces permissions as it sees fit and GB will honor whatever request it receives as long as it follows the oauth enforcement. There will be a developer mode where the oauth requirement will be off and we just make requests. This off mode will be the default.

<br><br>

# State Changes Requiring Events

* Consumer creation [registration]
* Consumer update
* Consumer deletion [unregistration]
* Owner creation
* Owner update
* Owner deletion
* Guest Consumer create
* Guest Consumer delete 
* Entitlement attachment
* Entitlement removal
* Entitlement regeneration
* Entitlement update [allowed for quantity only at current]
* Rules update
* Product update

<br><br>

#Sample Events

### Consumer Create

```json
{
  "id": null,
  "type": "CREATED",
  "target": "CONSUMER",
  "targetName": "dhcp137-159.rdu.redhat.com",
  "serverId": "some yet to be determined server id",
  "principalStore": "{"type":"user","name":"admin"}",
  "timestamp": 1401895505025,
  "entityId": "8a8d090f466770100146677bc87b0000",
  "ownerId": "8a8d090f465cec5c01465cec77400002",
  "consumerId": "8a8d090f466770100146677bc87b0000",
  "referenceId": null,
  "referenceType": null,
  "oldEntity": null,
  "newEntity": "{
	  "id": "8a8d090f466770100146677bc87b0000",
	  "uuid": "e5380375-e643-48a0-bf10-eb363a2cc9b4",
	  "name": "dhcp137-159.rdu.redhat.com",
	  "username": "admin",
	  "entitlementStatus": null,
	  "serviceLevel": "",
	  "releaseVer": {
	    "releaseVer": null
	  },
	  "idCert": {
	    "key": "-----BEGIN RSA PRIVATE KEY-----
			MIIEpAI...418GvLQ==
                    -----END RSA PRIVATE KEY-----",
	    "cert": "-----BEGIN CERTIFICATE-----
			MIIDfDC...bkj\/BhM=
			-----END CERTIFICATE-----",
	    "id": "8a8d090f466770100146677bcc200003",
	    "serial": {
	      "id": 8.931040548693e+18,
	      "revoked": false,
	      "collected": false,
	      "expiration": 1906817104165,
	      "serial": 8.931040548693e+18,
	      "created": 1401895504166,
	      "updated": 1401895504166
	    },
	    "created": 1401895504928,
	    "updated": 1401895504928
	  },
	  "type": {
	    "id": "1000",
	    "label": "system",
	    "manifest": false
	  },
	  "owner": {
	    "id": "8a8d090f465cec5c01465cec77400002",
	    "key": "admin",
	    "displayName": "Admin Owner",
	    "href": "/owners/admin"
	  },
	  "environment": null,
	  "entitlementCount": 0,
	  "facts": {
	    "lscpu.vendor_id": "GenuineIntel",
	    "dmi.chassis.power_supply_state": "Safe",
	    "net.interface.eth0.ipv6_netmask.link": "64",
	    "network.ipv4_address": "10.13.137.159",
	    "dmi.bios.rom_size": "64 KB",
	    "net.interface.lo.ipv6_netmask.host": "128",
	    "cpu.topology_source": "kernel /sys cpu sibling lists",
	    "dmi.chassis.thermal_state": "Safe",
	    "lscpu.l1i_cache": "32K",
	    "distribution.version": "20",
	    "dmi.bios.runtime_size": "96 KB",
	    "dmi.bios.bios_revision": "1.0",
	    "dmi.memory.array_handle": "0x1000",
	    "dmi.system.version": "Not Specified",
	    "virt.is_guest": "true",
	    "dmi.memory.total_width": "64 bit",
	    "memory.swaptotal": "2097148",
	    "net.interface.lo.ipv6_address.host": "::1",
	    "dmi.system.product_name": "Bochs",
	    "net.interface.eth0.ipv4_address": "10.13.137.178",
	    "system.certificate_version": "3.2",
	    "dmi.memory.size": "2048 MB",
	    "uname.version": "#1 SMP Tue May 13 13:51:08 UTC 2014",
	    "dmi.bios.version": "Bochs",
	    "dmi.chassis.version": "Not Specified",
	    "lscpu.cpu(s)": "1",
	    "lscpu.numa_node0_cpu(s)": "0",
	    "uname.nodename": "dhcp137-159.rdu.redhat.com",
	    "net.interface.eth0.mac_address": "52:54:00:0a:2c:45",
	    "dmi.chassis.security_status": "Unknown",
	    "dmi.memory.speed": "  (ns)",
	    "dmi.system.wake-up_type": "Power Switch",
	    "dmi.chassis.asset_tag": "Not Specified",
	    "memory.memtotal": "2050392",
	    "lscpu.on-line_cpu(s)_list": "0",
	    "dmi.memory.form_factor": "DIMM",
	    "dmi.processor.socket_designation": "CPU 1",
	    "lscpu.numa_node(s)": "1",
	    "lscpu.socket(s)": "1",
	    "dmi.system.status": "No errors detected",
	    "dmi.memory.data_width": "64 bit",
	    "net.interface.eth0.ipv4_netmask": "23",
	    "net.interface.lo.ipv4_address": "127.0.0.1",
	    "lscpu.stepping": "3",
	    "lscpu.cpu_family": "6",
	    "dmi.memory.maximum_capacity": "2 GB",
	    "net.interface.lo.ipv4_netmask": "8",
	    "dmi.processor.type": "Central Processor",
	    "lscpu.cpu_op-mode(s)": "32-bit, 64-bit",
	    "lscpu.byte_order": "Little Endian",
	    "dmi.memory.type": "RAM",
	    "network.hostname": "dhcp137-159.rdu.redhat.com",
	    "lscpu.core(s)_per_socket": "1",
	    "network.ipv6_address": "2620:52:0:d88:5054:ff:fe0a:2c45, fe80::5054:ff:fe0a:2c45",
	    "dmi.chassis.manufacturer": "Bochs",
	    "lscpu.cpu_mhz": "2127.998",
	    "net.interface.eth0.ipv4_broadcast": "10.13.137.255",
	    "dmi.system.uuid": "3d2295a0-f49c-bce7-ee05-43891554defd",
	    "virt.uuid": "3d2295a0-f49c-bce7-ee05-43891554defd",
	    "lscpu.model": "2",
	    "dmi.processor.upgrade": "Other",
	    "dmi.memory.error_correction_type": "Multi-bit ECC",
	    "lscpu.model_name": "QEMU Virtual CPU version 1.6.2",
	    "dmi.processor.family": "Other",
	    "lscpu.bogomips": "4255.99",
	    "cpu.thread(s)_per_core": "1",
	    "dmi.system.sku_number": "Not Specified",
	    "net.interface.eth0.ipv6_address.link": "fe80::5054:ff:fe0a:2c45",
	    "dmi.bios.vendor": "Bochs",
	    "distribution.id": "Heisenbug",
	    "dmi.memory.location": "Other",
	    "net.interface.eth0.ipv6_address.global": "2620:52:0:d88:5054:ff:fe0a:2c45",
	    "dmi.chassis.type": "Other",
	    "cpu.core(s)_per_socket": "1",
	    "cpu.cpu(s)": "1",
	    "dmi.chassis.serial_number": "Not Specified",
	    "lscpu.l1d_cache": "32K",
	    "virt.host_type": "kvm",
	    "dmi.memory.error_information_handle": "Not Provided",
	    "dmi.system.serial_number": "Not Specified",
	    "dmi.system.manufacturer": "Bochs",
	    "cpu.cpu_socket(s)": "2",
	    "lscpu.hypervisor_vendor": "KVM",
	    "lscpu.thread(s)_per_core": "1",
	    "dmi.bios.relase_date": "01/01/2011",
	    "dmi.chassis.boot-up_state": "Safe",
	    "lscpu.architecture": "x86_64",
	    "dmi.memory.use": "System Memory",
	    "dmi.processor.version": "Not Specified",
	    "dmi.memory.bank_locator": "Not Specified",
	    "lscpu.l2_cache": "4096K",
	    "net.interface.lo.ipv4_broadcast": "Unknown",
	    "dmi.system.family": "Not Specified",
	    "dmi.processor.voltage": " ",
	    "distribution.name": "Fedora",
	    "uname.sysname": "Linux",
	    "net.interface.eth0.ipv6_netmask.global": "64",
	    "uname.release": "3.14.4-200.fc20.x86_64",
	    "dmi.processor.status": "Populated:Enabled",
	    "uname.machine": "x86_64",
	    "dmi.memory.locator": "DIMM 0",
	    "dmi.bios.address": "0xe8000",
	    "dmi.chassis.lock": "Not Present",
	    "lscpu.virtualization_type": "full"
	  },
	  "lastCheckin": null,
	  "installedProducts": [
	    {
	      "id": "8a8d090f466770100146677bc8860001",
	      "productId": "37060",
	      "productName": "Awesome OS Server Bits",
	      "version": "6.1",
	      "arch": "ALL",
	      "status": null,
	      "startDate": null,
	      "endDate": null,
	      "created": 1401895504006,
	      "updated": 1401895504006
	    }
	  ],
	  "canActivate": false,
	  "guestIds": null,
	  "capabilities": null,
	  "hypervisorId": null,
	  "autoheal": true,
	  "href": "/consumers/e5380375-e643-48a0-bf10-eb363a2cc9b4",
	  "created": 1401895503995,
	  "updated": 1401895504929
	}",
  "messageText": null,
  "principal": {
    "type": "user",
    "name": "admin"
  }
}
```
<br>

### Entitlement create

```json
{
  "id": null,
  "type": "CREATED",
  "target": "ENTITLEMENT",
  "targetName": "Awesome OS Server Bundled",
  "serverId": "some yet to be determined server id",
  "principalStore": "{"type":"consumer","name":"e5380375-e643-48a0-bf10-eb363a2cc9b4"}",
  "timestamp": 1401895513345,
  "entityId": "8a8d090f466770100146677bea200005",
  "ownerId": "8a8d090f465cec5c01465cec77400002",
  "consumerId": "8a8d090f466770100146677bc87b0000",
  "referenceId": "8a8d090f465cec5c01465cecf3af1b44",
  "referenceType": "POOL",
  "oldEntity": null,
  "newEntity": "{
	  "id": "8a8d090f466770100146677bea200005",
	  "consumer": {
	    "id": "8a8d090f466770100146677bc87b0000",
	    "uuid": "e5380375-e643-48a0-bf10-eb363a2cc9b4",
	    "name": "dhcp137-159.rdu.redhat.com",
	    "href": "/consumers/e5380375-e643-48a0-bf10-eb363a2cc9b4"
	  },
	  "pool": {
	    "id": "8a8d090f465cec5c01465cecf3af1b44",
	    "productId": "awesomeos-server",
	    "productName": "Awesome OS Server Bundled",
	    "href": "/pools/8a8d090f465cec5c01465cecf3af1b44"
	  },
	  "certificates": [{
	      "key": "-----BEGIN RSA PRIVATE KEY-----
			MIIEpAI...418GvLQ==
			-----END RSA PRIVATE KEY-----
			",
	      "cert": "-----BEGIN CERTIFICATE-----
			MIIDmDC...f6V7whE8Jn
			-----END CERTIFICATE-----
			-----BEGIN ENTITLEMENT DATA-----
			eJzFVV1v...\/Q2+BJtb
			-----END ENTITLEMENT DATA-----
			-----BEGIN RSA SIGNATURE-----
			lLwUJN1j...1Un2tl8=
			-----END RSA SIGNATURE-----
			",
	      "id": "8a8d090f466770100146677bebc80006",
	      "serial": {
		"id": 3.8230594528522e+18,
		"revoked": false,
		"collected": false,
		"expiration": 1433203200000,
		"serial": 3.8230594528522e+18,
		"created": 1401895512845,
		"updated": 1401895512845
	      },
	      "created": 1401895513032,
	      "updated": 1401895513032
	    }
	  ],
	  "quantity": 1,
	  "startDate": 1401667200000,
	  "endDate": 1433203200000,
	  "href": "/entitlements/8a8d090f466770100146677bea200005",
	  "created": 1401895512608,
	  "updated": 1401895512608
	}",
  "messageText": null,
  "principal": {
    "type": "consumer",
    "name": "e5380375-e643-48a0-bf10-eb363a2cc9b4"
  }
}
```


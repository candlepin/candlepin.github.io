---
title: Fault_Tolerance_Design
categories: Designs
---
{% include toc.md %}

## Problem

Presently we have no way of tracking entitlements for each running instance of a virtual machine provided that each virtual machine has the same bios uuid. Tracking of entitlements is made even more difficult by technologies like vmware vLockstep etc that provide fault tolerant configurations. In these configurations there is a live backup vm that exactly duplicates the present state of the primary vm, meaning it cannot register to candlepin directly or have a different consumer_id. These fault tolerant configurations require the primary and backup vm to be on different hypervisors, meaning each vms compliance status could legitimately be quite different.

## Proposal

Create a consumer to represent the live backup instance that, in essence, cannot directly register itself. We can detect the need for these consumers by tracking additional information provided by virt-who (described at length below). Failover can be detected by changes in this information. When this happens the primary consumer is labelled 'failedover'. When the fault tolerant guest machine next checks in or otherwise accesses candlepin claiming to be the failed over consumer candlepin will throw a new exception that will include the identity cert of the now current consumer. Python-rhsm will have to be modified to catch the exception and replace the present identity cert with the new one. After that point everything resumes normal operation.

## Necessary Changes

In order to support Vmware Fault Tolerance, the following must be implemented:

- virt-who should report the following s new attributes per guest:
    - vm.config.ftinfo.{role, instanceUUIDs}
    - vm.config.instanceUUID

- Candlepin should:
    - Persist instanceUUIDs and associate them with consumers (stored as facts on the consumer that we only update server-side)
    - Apply actions made (attach, remove, register, unregister,etc) to all consumers that share the virt.uuid of the consumer that made the request
    - Create a consumer per (guest_id, instanceUUID) on hypervisor checkin.
    - Detect (using the new report info) when a fail over has occured.
        - Mark the original primary consumer (based on the ftinfo.role fact) as being a failed over state
        - Provide the correct identity cert to use if a guest claims to be a failed over consumer in a new exception
    - Check, on registration, if there is a consumer that exists already with the same virt.uuid as well as a ftinfo.role of 0, if so merge the info from registration into that consumer and return that one.

- Subscription-manager / python-rhsm:
    - Catch exceptions thrown by candlepin regarding failover detection.
        - When caught the local identity cert should be replaced by the one included in the exception
        - Entitlement certs should be refreshed after the new identity cert is in place.

----------------------------------------------------------------------------------------------------

# Use Case

## Preconditions
Candlepin has no record of the hypervisors, guests or consumers for them.

## Data

**Report 1**:

```json
{
    "Hypervisor A": {
        "vm1": {
            "virt.uuid": "VM1",    # this is the same as the virt.uuid fact reported from subman
            "instanceUUID": "VM_A",
            "ftinfo.role": "0",    # '0' means primary, all else backup
            "ftinfo.instanceUUIDS": ["VM_A", "VM_B"]
        }
    },
    "Hypervisor B": {
        "vm1": {
            "virt.uuid": "VM1",     # Same as above because this is the backup instance
            "instanceUUID": "VM_B",     # This field is actually a unique identifier
            "ftinfo.role": "1",    # Same as index of this guest's instanceUUID in the list below
            "ftinfo.instanceUUIDS": ["VM_A", "VM_B"]    # Exact same as before
        }
    }
}
```

**Report 2**:

```json
{
    "Hypervisor A": {...},    # The Fault tolerant VM from before is no longer here
    "Hypervisor B": {
        "vm1": {
            "virt.uuid": "VM1",
            "instanceUUID": "VM_B",
            "ftinfo.role": "0",    # This was 1 before the instance in hypervisor A failed
            "ftinfo.instanceUUIDS": ["VM_B", "VM_C"]    # A new backup vm has been created. It's instanceUUID has been added.
        }
    },
    "Hypervisor C": {
        "vm1": {
            "virt.uuid": "VM1",    # All instances that are part of this fault tolerant configuration will include the same virt.uuid
            "instanceUUID": VM_C",
            "ftinfo.role": "1",
            "ftinfo.instanceUUIDS": ["VM_B", "VM_C"]
        }
    }
}
```

### Parsing Report 1

{% plantuml %}
title Parsing Report 1
participant Candlepin as cp
database "Candlepin DB" as db

[-> cp: Report 1 received
cp -> cp: Parse Hypervisor A
activate cp
cp -> db: Get/create consumer for Hypervisor A
cp -> db: Get consumer where vm.uuid = vm1 and role = 0
cp <- db: Return None
create participant consumer1
cp -> consumer1: create new consumer
cp -> consumer1: set facts
rnote over consumer1
    virt.uuid = vm1
    instanceuuid = VM_A
    ftinfo.role = 0
    ftinfo.instanceuuids = [VM_A, VM_B]
end note
deactivate cp
cp -> cp: Parse Hypervisor B
activate cp
cp -> db: Get consumer for Hypervisor B
cp -> db: Get consumer where vm.uuid = vm1 and role = 1
cp <- db: Return None
create participant consumer2
cp -> consumer2: create new consumer for back up vm
cp -> consumer2: set facts
rnote over consumer2
    virt.uuid = vm1
    instanceuuid = VM_B
    ftinfo.role = 1
    ftinfo.instanceuuids = [VM_A, VM_B]
end note
deactivate cp
{% endplantuml %}{:.center-block}
----------------------------------------------------------------------------------------------------

### Vm Registration

{% plantuml %}
title VM registration
participant "Fault Tolerant VM" as vm
participant Candlepin as cp
database "Candlepin DB" as db

vm -> cp: Register (including fact virt.uuid = vm1)
cp -> db: Get consumer with virt.uuid = vm1 and role = 0
cp <- db: Return consumer1
cp -> consumer1: update facts with those provided from registration
vm <- cp: return consumer1
{% endplantuml %}
----------------------------------------------------------------------------------------------------


### Failover

{% plantuml %}
title Failover (Report 2)
participant "Fault Tolerant VM" as vm
participant Candlepin as cp
database "Candlepin DB" as db
participant consumer1
participant consumer2
[-> cp: Receive Report 2 from virt-who
cp -> consumer1: Change state / set fact 'Failover'
cp -> consumer2: Update role to 0 and other ftinfo
create participant consumer3
cp -> consumer3: Create consumer for new backup vm
cp -> consumer3: Ensure consumer consumes similar subs to consumer2
... Some time later ...
vm -> cp: Checkin / attach / etc (using consumer_id for consumer1)
cp -> consumer1: Check failover state
cp <- consumer1: Failover = true
cp -> db: Get consumer with virt.uuid = vm1 and role = 0
cp <- db: Return consumer2
vm <- cp: Raise FailoverException and return identity cert of consumer2
vm -> vm: Replace existing identity cert with the new one
vm -> cp: Refresh certs / entitlements
vm <- cp: Certs / entitlements for consumer2
{% endplantuml %}


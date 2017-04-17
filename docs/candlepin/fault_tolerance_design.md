---
title: Fault_Tolerance_Design
categories: Designs
---
{% include toc.md %}

# PR for review
Please use the PR located
[here](https://github.com/Candlepin/Candlepinproject.org/pull/67)
for any review and / or discussion of open questions or requirements


## Problem

Presently we have no way of tracking entitlements for each running instance of
a virtual machine if each virtual machine has the same BIOS UUID. Technologies
like VMware vLockstep, which provide fault tolerant configurations, make
tracking entitlements even more difficult. In these configurations, there is a
live backup VM that duplicates the present state of the primary VM, meaning it
cannot register to Candlepin directly or have a different consumer_id. These
fault tolerant configurations require the primary and backup VM to be on
different hypervisors, meaning each VM's compliance status could legitimately
be quite different.

### Requirements

These are the requirements I have been designing around:

- [Regarding two machines running in a fault tolerant configuration] From a
  business stand-point these are two different systems and each should be using
  a different subscription.
- Reference [BZ](https://bugzilla.redhat.com/show_bug.cgi?id=1235727)
- The compliance status of each instance should be independant of the status of
  other instances (one could be green in one place and red in another)
- Each instance should be entitled based on its hypervisor and consume the
  appropriate entitlements.

## Proposal

Create a consumer to represent the live backup instance that, in essence,
cannot directly register itself. We can detect the need for these consumers by
tracking additional information provided by virt-who (described at length
below). Failover can be detected by changes in this information. When this
happens the primary consumer is labelled 'failedover'. When the fault tolerant
guest machine next checks in or otherwise accesses Candlepin claiming to be the
failed over consumer, Candlepin will return the identity cert of the now
current consumer with a different http code (perhaps 205, or 3xx). Python-rhsm
will have to be modified to deal with this response code and replace the
present identity cert with the new one.  After that point everything resumes
normal operation.

## Necessary Changes

In order to support VMware Fault Tolerance, the following must be implemented:

- virt-who should report the following new attributes per guest:
    - vm.config.ftinfo.{role, instanceUUIDs}
    - vm.config.instanceUUID

- Candlepin should:
    - Persist instanceUUIDs and associate them with consumers (stored as facts
      on the consumer that we only update server-side)
    - Create a consumer per (guest_id, instanceUUID) on hypervisor checkin.
        - Do not set the org for these consumers initially.
        - The org for all of these consumers will be set based on what is
          submitted when the VM registers
            - Setting the org on registration implies that the set of all
              consumers that collectively represents this fault tolerant VM
              will be part of the same org.
    - Detect (using the new report info) when a fail over has occured.
        - Mark the original primary consumer (based on the ftinfo.role fact) as
          being a failed over state
        - Provide the correct identity cert to use if a guest claims to be a
          failed over consumer in a new exception
    - Check, on registration, if there is a consumer that exists already with
      the same virt.uuid as well as a ftinfo.role of 0. If so merge the info
      from registration into that consumer and return it.
    - Add the hypervisorId to the virt-only pools created
        - This will simplify the logic of attaching to the pool provided for
          the consumer
        - It also should allow sharing of such subs across orgs
    - If there are hypervisors that provide subscriptions from different orgs
      (orgs other than the org to which all the consumers for this fault
      tolerant configuration are registered), then the subs they provide must
      be shared with the org the fault tolerant VM was registered to in order
      for them to be consumed.

- Subscription-manager / python-rhsm:
    - Catch exceptions thrown by Candlepin regarding failover detection.
        - When caught the local identity cert should be replaced by the one
          included in the exception
        - Entitlement certs should be refreshed after the new identity cert is
          in place.

## How this affects Katello

This section will include thoughts on how this will affect katello after this
design is discussed with folks who work on Katello.

## Open Questions

- How do the appropriate subs get attached to the backup consumers? At this
  point we can detect and create consumers for the multiple instances of the
  same VM.
- When we attach to a particular pool via the command line on the primary VM,
  what do we do for the back up VMs? We cannot necessarily consume from the
  same pool as that contract might not have enough available to do so (but
  there might be a pool that provides similar products).
    - Do we auto attach with a limit on the products provided by the pool that
      was attached to the primary?
    - Do we leave the backup guests alone expecting the customer to attach the
      appropriate subscriptions via customer portal or Katello?
- Do we auto attach for the backup consumers when the primary auto attaches?
- Are we ok with the fact that this design implies that a fault tolerant VM
  might lose access to content on failover (if the backups were not able to be
  subscribed automatically or not properly subscribed manually)?


------------------------------------------------------------------------------

# Use Case

## Preconditions
Candlepin has no record of the hypervisors, guests or consumers for them.

## Data

**Report 1**:

```json
{
    "Hypervisor A": {
        "vm1": {
            "virt.uuid": "VM1",    # same as the virt.uuid fact from subman
            "instanceUUID": "VM_A",
            "ftinfo.role": "0",    # '0' means primary, all else backup
            "ftinfo.instanceUUIDS": ["VM_A", "VM_B"]
        }
    },
    "Hypervisor B": {
        "vm1": {
            "virt.uuid": "VM1",    # Same because this is the backup instance
            "instanceUUID": "VM_B",    # This field is a unique identifier
            "ftinfo.role": "1",
            "ftinfo.instanceUUIDS": ["VM_A", "VM_B"]    # Exact same as before
        }
    }
}
```

**Report 2**:

```json
{
    "Hypervisor A": {...},    # The primary VM from before is no longer here
    "Hypervisor B": {
        "vm1": {
            "virt.uuid": "VM1",
            "instanceUUID": "VM_B",
            "ftinfo.role": "0",    # Previously '1' before failover
            # The new backup VM's instanceUUID has been added.
            "ftinfo.instanceUUIDS": ["VM_B", "VM_C"]
        }
    },
    "Hypervisor C": {
        "vm1": {
            "virt.uuid": "VM1",
            "instanceUUID": "VM_C",
            "ftinfo.role": "1",
            "ftinfo.instanceUUIDS": ["VM_B", "VM_C"]
        }
    }
}
```

### Parsing Report 1

{% plantuml %}
title Parsing Report 1
participant "Virt-who" as vw
participant Candlepin as cp
database "Candlepin DB" as db

vw -> cp: Report 1
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
------------------------------------------------------------------------------

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
------------------------------------------------------------------------------

### VM Attach Activity Diagram

Diagram to follow shortly

------------------------------------------------------------------------------

### VM Unregister

Diagram to follow shortly

------------------------------------------------------------------------------

### Failover

{% plantuml %}
title Failover (Report 2)
participant "Virt-who" as vw
participant "Fault Tolerant VM" as vm
participant Candlepin as cp
database "Candlepin DB" as db
participant consumer1
participant consumer2
vw -> cp: Report 2
cp -> consumer1: Change state / set fact 'Failover'
cp -> consumer2: Update role to 0 and other ftinfo
create participant consumer3
cp -> consumer3: Create consumer for new backup VM
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

-------------------------------------------------------------------------------

# Activity diagrams

## Look up and verify consumer

{% plantuml %}
title Lookup and Verify Consumer
start
:Look up consumer;
if (consumer has ftinfo?) then (True)
    if (consumer.failedOver?) then (True)
        :Get next consumer from db with ftinfo.role=0;
        if (nextConsumer != null) then (True)
            :Throw FailoverDetectedException
            Include the next consumer and
            next consumer identity cert;
            stop
        else (False)
            :Proceed as normal;
            stop
        endif
    else (False)
        :Proceed as normal;
        stop
    endif
else (False)
    :Proceed as normal;
    stop
endif

{% endplantuml %}

--------------------------------------------------------------------------------



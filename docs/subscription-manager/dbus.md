---
categories: developers
title: D-Bus use in Subscription Manager
---
{% include toc.md %}

# D-Bus

Subscription Manger creates D-Bus messages when the entitlement staus changes. 

<br>
<br>

## Signals

There are 2 signals that correspond to the messages that are sent:

```python
    @dbus.service.signal(
        dbus_interface='com.redhat.SubscriptionManager.EntitlementStatus',
        signature='i')
    def entitlement_status_changed(self, status_code):
```
```python
    @dbus.service.signal(
        dbus_interface='com.redhat.SubscriptionManager.EntitlementStatus',
        signature='a{s(ss)}')
    def entitlement_status_changed_reason(self, reason):
```

<br>
<br>

## Messages

The first contains a code with the status of the machine. It is consumed by the process rhsm_icon. This is the alert bubble that informs the user of the entitlement status. The messages displayed there are keyed from the interger value. Those messages are not specific to actual installed products.

The second contains a dictionary that uses the unique identifier [SKU] of each installed prodcut as a key. The value is a tuple that contains the name of the installed product and the compliance message for the product. Only products that are not fully entitled will appear in this data set. Also included in this dictionary is a value with key 'system_status'. The first member of the tuple value has the one word status and the second member is blank.

<br>

#### Output from a D-Bus perspective:

```console
$ dbus-monitor --system --monitor

signal sender=:1.108 -> dest=(null destination) serial=4 path=/EntitlementStatus; interface=com.redhat.SubscriptionManager.EntitlementStatus; member=entitlement_status_changed
   int32 1
signal sender=:1.108 -> dest=(null destination) serial=5 path=/EntitlementStatus; interface=com.redhat.SubscriptionManager.EntitlementStatus; member=entitlement_status_changed_reason
   array [
      dict entry(
         string "system_status"
         struct {
            string "invalid"
            string ""
         }
      )
      dict entry(
         string "37069"
         struct {
            string "Management Bits"
            string "Not supported by a valid subscription."
         }
      )
```

<br>
<br>

## On Demand Message Production

There is also a means to 'poke' the rhsm daemon to make it produce the above messages with the current status on demand:

```python
    @dbus.service.method(
        dbus_interface="com.redhat.SubscriptionManager.EntitlementStatus",
        out_signature='i')
    def check_status(self):
```

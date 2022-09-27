---
title: D-Bus use in Subscription Manager
---
{% include toc.md %}

# D-Bus

Subscription Manger creates D-Bus messages when the entitlement status changes.

## Signals

There are two signals that correspond to the messages that are sent:

```python
    @dbus.service.signal(
        dbus_interface='com.redhat.SubscriptionManager.EntitlementStatus',
        signature='i')
    def entitlement_status_changed(self, status_code):
```

```python
    @dbus.service.signal(dbus_interface=dbus.PROPERTIES_IFACE,
                         signature="sa{sv}as")
    def PropertiesChanged(self, interface_name, changed_properties,
                          invalidated_properties):
```

## Messages

The first contains a code with the status of the machine. It used to be consumed by the process `rhsm_icon`. The messages displayed there are keyed from the integer value. Those messages are not specific to actual installed products.

The second contains a dictionary that contains 3 parameters: Version, Status, and Entitlements. Version and Status [enum below] have single string values. Entitlements is a dictionary that uses the unique identifier [SKU] of each installed product as a key. The value is a tuple that contains the name of the installed product, a state code [enum below], and the compliance message for the product. All installed products will appear in this data set.

`statuses = ["valid", "invalid", "partial", "unknown"]`

`states = ["future_subscribed", "subscribed", "not_subscribed", "expired", "partially_subscribed"]`

### Output from a D-Bus perspective:

```console
$ dbus-monitor --system --monitor

signal sender=:1.10 -> dest=(null destination) serial=4 path=/EntitlementStatus; interface=com.redhat.SubscriptionManager.EntitlementStatus; member=entitlement_status_changed
   int32 1
signal sender=:1.10 -> dest=(null destination) serial=5 path=/EntitlementStatus; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged
   string "com.redhat.SubscriptionManager"
   array [
      dict entry(
         string "Status"
         variant             string "invalid"
      )
      dict entry(
         string "Entitlements"
         variant             array [
               dict entry(
                  string "37069"
                  struct {
                     string "Management Bits"
                     string "not_subscribed"
                     string "Not supported by a valid subscription."
                  }
               )
               dict entry(
                  string "37068"
                  struct {
                     string "Large File Support Bits"
                     string "not_subscribed"
                     string "Not supported by a valid subscription."
                  }
               )
             ]
      )
      dict entry(
         string "Version"
         variant             string "1.0"
      )
   ]
   array [
   ]

```

In a scenario where the machine is unregistered, the output for PropertiesChanged will appear as follows:

```console
signal sender=:1.8 -> dest=(null destination) serial=5 path=/EntitlementStatus; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged
   string "com.redhat.SubscriptionManager"
   array [
      dict entry(
         string "Status"
         variant             string "System is not registered."
      )
      dict entry(
         string "Version"
         variant             string "1.0"
      )
   ]
   array [
   ]

```

## On Demand Message Production

There is a means to 'poke' the rhsm daemon to make it produce the first message on demand:

```python
    @dbus.service.method(
        dbus_interface="com.redhat.SubscriptionManager.EntitlementStatus",
        out_signature='i')
    def check_status(self):
```

Entitlement Status employs the standard Properties interface methods:

```python
    @dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
                         in_signature="ss", out_signature="v")
    def Get(self, interface_name, property_name):

    @dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
                         in_signature="s", out_signature="a{sv}")
    def GetAll(self, interface_name):
```

As the available information is read-only, no other access retrictions have been implemented. If the capabilities are expanded in the future to include system manipulation, then access control will be added.

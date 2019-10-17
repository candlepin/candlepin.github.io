---
title: Subscription Manager D-Bus Objects
---
{% include toc.md %}

Subscription-manager exposes several DBus objects under the bus name
`com.redhat.RHSM1`. Subscription-manager expects to attach to the system bus
although the session bus may be used for smoke testing (with the expectation
that several calls will not work due to lack of permissions).

> Note: for array types ("a" followed by another type, for example "as" for string array or "a{sv} for dictionary"), input the number of elements in the array and then the elements in the array. For example, string array ["foo"] would be input as 1 "foo".

# Attach

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Attach`
* Bus path: `/com/redhat/RHSM1/Attach`

The Attach object provides an interface to attach subscriptions to the system.

## Methods

* `AutoAttach(string, dictionary(string, variant), string)`: Perform an auto-attach on
  the system.  A service level (or empty string for none) is provided as the
  first parameter and a dictionary of proxy options for the second.
* `PoolAttach(array(string), id, dictionary(string, variant), string)`: Attach
  specific pools to the system.  The first parameter is a list of pool IDs, the
  second a quantity, and the final parameter is a dictionary of proxy options.

### Examples

* Example of attaching to pool using Pool ID (quantity is one)

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Attach com.redhat.RHSM1.Attach PoolAttach asia{sv}s 1 4028fa7a5e9e7fe9015e9e84ea2a0317 1 0 ""
  ```

* Example of auto-attaching (service level not specified)

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Attach com.redhat.RHSM1.Attach AutoAttach sa{sv}s "" 0 ""
  ```

# Configuration

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Config`
* Bus path: `/com/redhat/RHSM1/Config`

The Config object offers a very simple interface to inspect or edit
subscription-manager's configuration settings.

## Methods

* `Get(string, string)`: Get a section or a specific setting.  E.g. `Get('rhsm', 'en_EN')` or
  `Get('rhsm.baseurl', '')`
* `GetAll(string)`: Get all configuration settings
* `Set(string, variant, string)`: Set a setting to a value

### Examples

* Example of getting all configuration:

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Config com.redhat.RHSM1.Config GetAll s ""
  ```

* Example of getting specific option:

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Config com.redhat.RHSM1.Config Get ss "rhsm.baseurl" ""
  ```

* Example of setting specific option:

  ```console
  $ busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Config com.redhat.RHSM1.Config Set svs "server.insecure" s "1" ""
  ```

> Note: All methods have at least one string argument. This last string argument can be empty string or it can specify locale. When locale string is set to supported locale, then RHSM service will try to translate some strings and error messages.

# Consumer

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Consumer`
* Bus path: `/com/redhat/RHSM1/Consumer`

The Consumer object provides an interface to get the current UUID of the consumer. This object can also broadcast a signal when consumer is created, changed, or removed.

## Methods

* `GetUuid(string)`: Returns string representing current UUID. When the system is not registered, then this method returns empty string. This method has only one string argument and it is locale.

## Signals

* `ConsumerChanged()`: This signal is broadcasted when consumer is created/changed/removed.

### Examples

* Example of getting current consumer UUID

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Consumer com.redhat.RHSM1.Consumer GetUuid s ""
  ```

# Entitlement

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Entitlement`
* Bus path: `/com/redhat/RHSM1/Entitlement`

The Entitlement object interacts with subscription-manager to list, get status, and remove pools. This object can also broadcast a signal when entitlements are created, changed, or removed.

## Methods

* `GetStatus(string, string)`: Returns string representing current status of entitlements. The first string argument is the date the user is interested in getting the status for; the second string argument is the locale
* `GetPools(dictionary(string, variant), dictionary(string, variant), string)`: Tries to get pools installed/available/consumed on this system; returns a string. The first dictionary argument is a DBus object storing options of query. Available options keys: `pool_subsets`, `matches`, `pool_only`, `match_installed`, `match_installed`, `no_overlap`, `service_level`, `show_all`, `on_date`, `future`, `after_date`. The second dictionary argument is a DBus object with proxy configuration; the third argument is a string representing the locale.
* `RemoveAllEntitlements(dictionary(string, variant), string)`: Returns JSON string containing response of trying to remove all entitlements (subscriptions) from the system. The first dictionary argument stores the proxy configuration; the string argument is the locale.
* `RemoveEntitlementsByPoolIds(array(string), dictionary(string, variant), string)`: Returns a JSON string representing a list of serial numbers after trying to remove entitlements (subscriptions) by pool ids. The first array argument is the list of pool ids; the second argument is a dictionary containing the proxy configuration; the third argument is a string representing locale.
* `RemoveEntitlementsBySerials(array(string), dictionary(string, variant), string)`: Returns a JSON string representing a list of serial numbers corresponding to entitlements successfully removed after trying to remove entitlements (subscriptions) by serials. The first array argument is the list of serial numbers of subscriptions

### Examples

* Example of getting all pools

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement GetPools a{sv}a{sv}s 0 0 ""
  ```

* Example of getting installed pools:

  ```console
  $ sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement.GetPools dict:string:string:"pool_subsets","installed" dict:string:string:"","" string:""
  ```

* Example of getting consumed pools:

  ```console
  $ sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement.GetPools dict:string:string:"pool_subsets","consumed" dict:string:string:"","" string:""
  ```

* Example of getting available pools:

  ```console
  $ sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement.GetPools dict:string:string:"pool_subsets","consumed" dict:string:string:"","" string:""
  ```

* Example of removing all entitlements

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement RemoveAllEntitlements a{sv}s 0 ""
  ```

* Example of removing entitlements by pool ids

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement RemoveEntitlementsByPoolIds asa{sv}s 0 0 ""
  ```

* Example of removing entitlements by serials

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement RemoveEntitlementsBySerials asa{sv}s 0 0 ""
  ```

# Facts

* Bus name: `com.redhat.RHSM1.Facts`
* Interfaces: `com.redhat.RHSM1.Facts`
* Bus path: `/com/redhat/RHSM1/Facts`

The Facts object queries a system's dmiinfo to determine relevant facts about a
system: e.g. system architecture, etc.  This object must be running on the
system bus in order to work properly.  The Facts object path has several
children representing different classifications of facts:

* Custom: custom facts defined by the user.
* Hardware: facts related to system hardware.
* Host: facts related to virtualization.
* Static: facts that are unchanging.  Generally related to subscription-manager
  internals.

## Methods

All of these object paths use the same interface, `com.redhat.RHSM1.Facts` which
has only one method: `GetFacts()`.  Calling `GetFacts()` on the Facts object
path gives an aggregate of all the children otherwise each child only reports
the facts it is responsible for.  Also note that any fact defined as a custom
fact will override the same fact in a sibling.

# Products

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Products`
* Bus path: `/com/redhat/RHSM1/Products`

The Products object provides an interface to list installed products.

## Methods

* `ListInstalledProducts(string, dictionary(string, variant), string)`: Return
  list of installed products. The argument order is: `filter, options dictionary`.
  The `filter` argument can be used to filter out some products from returned
  list of installed products. The options dictionary contains proxy options.
  This call returns the JSON list of installed products.

### Examples

* Example of listing of installed products

  ```console
  $ sudo dbus-send --system --print-reply --dest='com.redhat.RHSM1' '/com/redhat/RHSM1/Products' com.redhat.RHSM1.Products.ListInstalledProducts string:"" dict:string:string:"","" string:""
  ```

# Register

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Register`
* Bus path: `/com/redhat/RHSM1/Register`

**This service is normally exposed only over a domain socket.**  `Register` is
the object attached to the domain socket server that the `RegisterServer`
creates.

## Methods

* `Register(string, string, string, dictionary(string, variant),
  dictionary(string, variant), string)`: Register a system via subscription-manager. The
  argument order is `organization, username, password, options dictionary,
  connection options dictionary`, locale.

  The options dictionary can contain the keys

  * `force`: force a registration
  * `name`: specify a consumer name; defaults to the system hostname
  * `consumerid`: register with an existing consumer ID
  * `environment`: register to a given environment

  The connection options dictionary can contain the keys

  * `host`: the subscription management server host
  * `port`: the subscription management server port
  * `handler`: the context of the subscription management server.  E.g.
    `/subscriptions`
  * `insecure`: disable SSL/TLS host verification
  * `proxy_hostname`
  * `proxy_user`
  * `proxy_password`

  The call returns the JSON response body from the subscription management
  server.

* `RegisterWithActivationKeys(string, array(strings), dictionary(string,
  variant), dictionary(string, variant), string)`: Register a system using one or more
  activation keys.  The argument order is `organization, activation key list,
  options dictionary, connection options dictionary`. The options dictionary
  should only contain `name` and/or `force` since activation keys cannot be used
  with environments or existing consumer IDs.  The connection options dictionary
  can contain the same values as `Register`.  This call returns the JSON
  response body from the subscription management server.

### Examples

* Example of registration using username, password and organization

  ```console
  $ dbus-send --address="unix:abstract=/var/run/dbus-1wK4IpDyx1,guid=bb37a25a294373d92315c10a5995f41f" --print-reply --dest='com.redhat.RHSM1.Register' '/com/redhat/RHSM1/Register' com.redhat.RHSM1.Register.Register string:"admin" string:"admin" string:"admin" dict:string:string:"","" dict:string:string:"","" string:""
  ```

# RegisterServer

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.RegisterServer`
* Bus path: `/com/redhat/RHSM1/RegisterServer`

The RegisterServer object is used to start *another* DBus object listening on a
Unix domain socket instead of on the session or system bus. By using a domain
socket for communication, callers can send credentials securely since
information sent over the session or system bus can be susceptible to
eavesdropping.

## Methods

* `Start(string)`: starts the domain socket listener and returns the address of the
  domain socket. This address can is used for service `Register`.
* `Stop(string)`: stop the domain socket server

### Examples

* Example of starting domain socket listener

  ```console
  $ sudo dbus-send --system --print-reply --dest='com.redhat.RHSM1' '/com/redhat/RHSM1/RegisterServer' com.redhat.RHSM1.RegisterServer.Start string:""
  ```

  returns following text to `stdout`:

  ```console
  method return sender=:1.352 -> dest=:1.362 reply_serial=2
   string "unix:abstract=/var/run/dbus-1wK4IpDyx1,guid=bb37a25a294373d92315c10a5995f41f"
  ```

* Example of stopping domain socket listener

  ```console
  $ sudo dbus-send --system --print-reply --dest='com.redhat.RHSM1' '/com/redhat/RHSM1/RegisterServer' com.redhat.RHSM1.RegisterServer.Stop string:""
  ```

# System Purpose

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Syspurpose`
* Bus path: `/com/redhat/RHSM1/Syspurpose`

The Syspurpose object interacts with subscription-manager to get information about current system purpose

## Methods

* `GetSyspurpose(string)`: DBus method for getting current system purpose. Argument represents locale.
* `GetSyspurposeStatus()`: DBus method for getting current system purpose status.

### Examples

* Example of getting system purpose

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetSyspurpose s ""
  ```

* Example of getting system purpose status

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetSyspurposeStatus
  ```

# Unregister

* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Unregister`
* Bus path: `/com/redhat/RHSM1/Unregister`

The Unregister object provides an interface to unregister a system via
subscription-manager.

## Methods

* `Unregister(dictionary(string, variant), string)`: Unregister a system via
  subscription-manager. The Unregister method has one argument: dictionary
  with proxy options. This call returns the JSON response body from the
  subscription management server.

### Examples

* Example of unregistering system:

  ```console
  $ sudo dbus-send --system --print-reply --dest='com.redhat.RHSM1' '/com/redhat/RHSM1/Unregister' com.redhat.RHSM1.Unregister.Unregister dict:string:string:"","" string:""
  ```

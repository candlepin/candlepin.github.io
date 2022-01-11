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

## Signals

* `ConfigChanged()`: This signal is broadcasted, when configuration file was created/changed/deleted.

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

* `GetStatus(string, string)`: Returns string with JSON document representing current status of entitlements. The first string argument is the date the user is interested in getting the status for; the second string argument is the locale. It can returns following string with JSON document:

```json
{
  "status": "Invalid",
  "status_id": "invalid",
  "reasons": {
    "SP Server Bits": [
      "Not supported by a valid subscription."
    ]
  },
  "reason_ids": {
    "99000": [
      {
        "key": "NOTCOVERED",
        "product_name": "SP Server Bits"
      }
    ]
  },
  "valid": false
}
```

  The meaning of each key is as follows:

  * `status`: Status of system. This string is a textual description of the status, translated to the specified locale. It can be used in UI strings shown to the user. The value should never been used in code for checking the state of system. For this purpose we have following key.
  * `status_id`: Code of system status. This key can have following values:
    * `valid`: System is registered and all installed products are covered by subscriptions
    * `invalid`: System is registered, but no subscriptions are attached
    * `partial`: System is registered, but there some products that are only partially entitled
    * `disabled`: System is registered, but it uses SCA mode
    * `unknown`: System is not registered
  * `reasons`: Textual representation of reasons, why status is invalid. There could be more products that are not entitled and there could be more reasons, why product is not entitled. Strings are again textual description of the reasons, translated to the specified locale. It can be used in UI strings shown to the user.
  * `reason_ids`: Dictionary with reasons, why each product is not entitled or is only partially entitled. Keys of dictionary are IDs of product (99000 in this case). The `key` contains code generated by candlepin server, why product is not entitled. It also contains `product_name` to be able link textual representation of reason with this code (e.g. to be able to display textual representation of reason with different color).
  * `valid`: The value of this key is true, when system is registered and all products are entitled.

* `GetPools(dictionary(string, variant), dictionary(string, variant), string)`: Tries to get pools installed/available/consumed on this system; returns a string. The first dictionary argument is a DBus object storing options of query. Available options keys: `pool_subsets`, `matches`, `pool_only`, `match_installed`, `match_installed`, `no_overlap`, `service_level`, `show_all`, `on_date`, `future`, `after_date`. The second dictionary argument is a DBus object with proxy configuration; the third argument is a string representing the locale.
* `RemoveAllEntitlements(dictionary(string, variant), string)`: Returns JSON string containing response of trying to remove all entitlements (subscriptions) from the system. The first dictionary argument stores the proxy configuration; the string argument is the locale.
* `RemoveEntitlementsByPoolIds(array(string), dictionary(string, variant), string)`: Returns a JSON string representing a list of serial numbers after trying to remove entitlements (subscriptions) by pool ids. The first array argument is the list of pool ids; the second argument is a dictionary containing the proxy configuration; the third argument is a string representing locale.
* `RemoveEntitlementsBySerials(array(string), dictionary(string, variant), string)`: Returns a JSON string representing a list of serial numbers corresponding to entitlements successfully removed after trying to remove entitlements (subscriptions) by serials. The first array argument is the list of serial numbers of subscriptions

## Signals

* `EntitlementChanged()`: This signal is broadcasted, when some entitlement certificated is created/changed/deleted.

### Examples

* Example of getting status:

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement GetStatus ss "" ""
  ```

* Example of getting all pools:

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
  $ sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1 /com/redhat/RHSM1/Entitlement com.redhat.RHSM1.Entitlement.GetPools dict:string:string:"pool_subsets","available" dict:string:string:"","" string:""
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

### Examples

* Example of getting all facts:

  ```console
  $ sudo busctl call com.redhat.RHSM1.Facts /com/redhat/RHSM1/Facts com.redhat.RHSM1.Facts GetFacts
  ```

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


## Signals

* `InstalledProductsChanged`: This signal is broadcasted, when some product certificated is created/changed/deleted.

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
  server. Example of JSON document returned after sucessful registration:

  ```json
{
    "created": "2021-04-21T08:56:16+0000",
    "updated": "2021-04-21T08:56:18+0000",
    "id": "ff80808178f377570178f3a4f26c0bc8",
    "uuid": "bf571fef-ae87-4805-88fc-acbf24d2c465",
    "name": "localhost",
    "username": "admin",
    "entitlementStatus": "invalid",
    "serviceLevel": "",
    "role": "",
    "usage": "Production",
    "addOns": [],
    "systemPurposeStatus": "mismatched",
    "releaseVer": {
        "releaseVer": null
    },
    "owner": {
        "id": "ff80808178f377570178f3778be00002",
        "key": "admin",
        "displayName": "Admin Owner",
        "href": "/owners/admin"
    },
    "environment": null,
    "entitlementCount": 0,
    "facts": {
        "some.fact": "foo [redacted]",
    },
    "lastCheckin": null,
    "installedProducts": [
        {
            "created": "2021-04-21T08:56:16+0000",
            "updated": "2021-04-21T08:56:16+0000",
            "id": "ff80808178f377570178f3a4f26d0bca",
            "productId": "38072",
            "productName": "Fake OS Bits",
            "version": "1.0",
            "arch": "ALL",
            "status": null,
            "startDate": null,
            "endDate": null
        }
    ],
    "canActivate": false,
    "capabilities": null,
    "hypervisorId": {
        "created": "2021-04-21T08:56:16+0000",
        "updated": "2021-04-21T08:56:16+0000",
        "id": "ff80808178f377570178f3a4f26d0bcb",
        "hypervisorId": "fb61574c-2e86-11b2-a85c-d7b6de34018c",
        "reporterId": null
    },
    "contentTags": [],
    "autoheal": true,
    "annotations": null,
    "contentAccessMode": null,
    "type": {
        "created": null,
        "updated": null,
        "id": "1000",
        "label": "system",
        "manifest": false
    },
    "idCert": {
        "created": "2021-04-21T08:56:18+0000",
        "updated": "2021-04-21T08:56:18+0000",
        "id": "ff80808178f377570178f3a4fa620bcd",
        "key": "Some RSA PRIVATE KEY [redacted]",
        "cert": "Some CERTIFICATE [redacted]",
        "serial": {
            "created": "2021-04-21T08:56:16+0000",
            "updated": "2021-04-21T08:56:16+0000",
            "id": 2157749916828659606,
            "serial": 2157749916828659606,
            "expiration": "2037-04-21T08:56:16+0000",
            "collected": false,
            "revoked": false
        }
    },
    "guestIds": [],
    "href": "/consumers/bf571fef-ae87-4805-88fc-acbf24d2c465",
    "activationKeys": []
}
  ```

  When not valid username/password is provided, then following error is returned:


  ```
  Error com.redhat.RHSM1.Error: {"exception": "RestlibException", "severity": "error", "message": "Invalid Credentials"}
  ```

  When valid username and password is provided, but not valid organization is provided,
  then following error is returned:

  ```
  Error com.redhat.RHSM1.Error: {"exception": "RestlibException", "severity": "error", "message": "Organization wrong-org does not exist."}
  ```


  Note: returned JSON document is generated by candlepin server (this example
  was generated by candlepin server 4.1.0-1) and generated JSON document can
  be different on other versions of candlepin server. JSON document is
  generated by this REST API endpoint:

  https://www.candlepinproject.org/swagger/?url=candlepin/swagger-3.1.16.json#!/consumers/create

* `RegisterWithActivationKeys(string, array(strings), dictionary(string,
  variant), dictionary(string, variant), string)`: Register a system using one or more
  activation keys.  The argument order is `organization, activation key list,
  options dictionary, connection options dictionary`. The options dictionary
  should only contain `name` and/or `force` since activation keys cannot be used
  with environments or existing consumer IDs.  The connection options dictionary
  can contain the same values as `Register`.  This call returns the JSON
  response body from the subscription management server. The returned document
  is very similar to response of `Register` method. There is only few differences.
  Returned document contains list of of `activationKeys` and `username` is `null`.
  Example activation keys:

  ```json
  "activationKeys": [
    {
      "activationKeyName": "admin-awesomeos-server-key-ff80808178f377570178f3788a0c022a",
      "activationKeyId": "ff80808178f377570178f379e88a0803"
    }
  ]
  ```

  When not valid organization is provided, then following error is returned:

  ```
  Error com.redhat.RHSM1.Error: {"exception": "RestlibException", "severity": "error", "message": "Organization wrong-org does not exist."}
  ```


  When not valid activation key is provided, then following error is returned:

  ```
  Error com.redhat.RHSM1.Error: {"exception": "RestlibException", "severity": "error", "message": "None of the activation keys specified exist for this org."}
  ```

* `GetOrgs(string, string, dictionary(string, variant), string)`:
  Get list of organizations for given user. The argument order is: `username, password,
  connection options dictionary, string with locale`. The connection options dictionary
  can contain the same values as `Register`. This call returns the JSON response
  body from the subscription management server. It is list of dictionaries. There are two
  important items `key` and `displayName`. The `key` is used in `Register()` method and
  `displayName` should be displayed to users. The `contentAccessMode` can have two values:
  `entitlement` and `org_environment`. This significantly influences entitlement workflow
  and how client should react on several situations.

  ```json
  [
    {
        "contentAccessModeList": "entitlement",
        "updated": "2020-02-17T08:21:47+0000",
        "displayName": "Donald Duck",
        "key": "donaldduck",
        "created": "2020-02-17T08:21:47+0000",
        "logLevel": null,
        "autobindHypervisorDisabled": false,
        "contentPrefix": null,
        "contentAccessMode": "entitlement",
        "href": "/owners/donaldduck",
        "lastRefreshed": null,
        "defaultServiceLevel": null,
        "parentOwner": null,
        "autobindDisabled": false,
        "upstreamConsumer": null,
        "id": "ff80808170523d030170523d34890003"
    }
  ]
  ```

### Examples

* Example of registration using username, password and organization

  ```console
  $ dbus-send --address="unix:abstract=/var/run/dbus-1wK4IpDyx1,guid=bb37a25a294373d92315c10a5995f41f" \
        --print-reply \
        --dest='com.redhat.RHSM1.Register' \
        '/com/redhat/RHSM1/Register' \
        com.redhat.RHSM1.Register.Register \
        string:"admin" \
        string:"admin" \
        string:"admin" \
        dict:string:string:"","" \
        dict:string:string:"","" \
        string:""
  ```

* Example of registration using organization ID and activation key:

  ```console
  $ dbus-send --address=unix:abstract=/var/run/dbus-1wK4IpDyx1,guid=bb37a25a294373d92315c10a5995f41f \
        --print-reply \
        --dest='com.redhat.RHSM1.Register' \
        '/com/redhat/RHSM1/Register' \
        com.redhat.RHSM1.Register.RegisterWithActivationKeys \
        string:"admin" \
        array:string:"admin-awesomeos-server-key-ff80808178f377570178f3788a0c022a" \
        dict:string:string:"","" \
        dict:string:string:"","" \
        string:""
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

* `GetSyspurpose(string)`: D-Bus method for getting current system purpose. Argument represents locale.
* `GetSyspurposeStatus(string)`: D-Bus method for getting current system purpose status. Argument represents locale.
* `GetValidFields(string)`: D-Bus method for getting valid system purpose fields (keys and values). Argument represents locale.
* `SetSyspurpose(dictionary(string, variant), string)`: D-Bus method for setting system purpose. First argument represents all system values that will be set and second argument represents locale.

## Signals

* `SyspurposeChanged()`: This signal is broadcasted, when `syspurpose.json` file is created/changed/deleted.

### Examples

* Example of getting system purpose

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetSyspurpose s ""
  ```

* Example of getting system purpose status

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetSyspurposeStatus s ""
  ```

* Example of getting valid system purpose

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetValidFields s ""
  ```

* Example of resetting all system purpose values

  ```console
  $ sudo busctl call com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose GetValidFields a{sv}s 0 ""
  ```

* Example of setting system purpose values. Note: Keep in mind that system purpose values not included in the D-Bus method call are reset to empty string or empty list (addons)

   ```console
   sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1 /com/redhat/RHSM1/Syspurpose com.redhat.RHSM1.Syspurpose.SetSyspurpose dict:string:string:"usage","Production","service_level_agreement","Premium" string:""
   ```

   System purpose will be following `{"usage": "Production", "addons": [], "service_level_agreement": "Premium", "role": ""}` after calling D-Bus method mentioned above, despite `role` or `addons` contained some values.

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

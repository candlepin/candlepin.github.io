---
title: Subscription Manager D-Bus Objects
---
{% include toc.md %}

Subscription-manager exposes several DBus objects under the bus name
`com.redhat.RHSM1`.  Subscription-manager expects to attach to the system bus
although the session bus may be used for smoke testing (with the expectation
that several calls will not work due to lack of permissions).

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

# Configuration
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Config`
* Bus path: `/com/redhat/RHSM1/Config`

The Config object offers a very simple interface to inspect or edit
subscription-manager's configuration settings.

## Methods
* `Get(string)`: Get a section or a specific setting.  E.g. `Get('rhsm')` or
  `Get('rhsm.baseurl')`
* `GetAll()`: Get all configuration settings
* `Set(string, variant)`: Set a setting to a value

# RegisterServer
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.RegisterServer`
* Bus path: `/com/redhat/RHSM1/RegisterServer`

The RegisterServer object is used to start *another* DBus object listening on a
Unix domain socket instead of on the session or system bus.  By using a domain
socket for communication, callers can send credentials securely since
information sent over the session or system bus can be susceptible to
eavesdropping.

## Methods
* `Start()`: starts the domain socket listener and returns the address of the
  domain socket
* `Stop()`: stop the domain socket server

# Register
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Register`
* Bus path: `/com/redhat/RHSM1/Register`

**This service is normally exposed only over a domain socket.**  `Register` is
the object attached to the domain socket server that the `RegisterServer`
creates.

## Methods
* `Register(string, string, string, dictionary(string, variant)`: Register a
  system via subscription-manager.  The argument order is `organization,
  username, password, options dictionary`.  The options dictionary can contain
  the keys

  * `host`: the subscription management server host
  * `port`: the subscription management server port
  * `handler`: the context of the subscription management server.  E.g.
    `/subscriptions`
  * `insecure`: disable SSL/TLS host verification
  * `environment`: the environment to register to
  * `name`: defaults to the system hostname
  * `proxy_hostname`
  * `proxy_user`
  * `proxy_password`

  The call returns the JSON response from the subscription management server.

* `RegisterWithActivationKeys(string, array(strings), dictionary(string,
  variant)`: Register a system using one or more activation keys.  The argument
  order is `organization, activation key list, options dictionary`.  The options
  dictionary can contain the same values as `Register`.  This call returns the
  JSON response from the subscription management server.

# Entitlement
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Entitlement`
* Bus path: `/com/redhat/RHSM1/Entitlement`

The Entitlement object provides an information about entitlements usable by a system.
Entitlement information provides:

   * an owner of the entitled subscriptions
   * a list of pools accessible by this system
   
## Methods
* `GetStatus()`: Returns a string describing a current entitlement status.

   * "Future Subscription"
   * "Subscribed"
   * "Not Subscribed"
   * "Expired"
   * "Partially Subscribed"
   * "Unknown"

```python
>>> GetStatus()
{"status": 0,
 "overall_status": "Invalid",
 "reasons": {"Awesome OS Modifier Bits": ["Not supported by a valid subscription."]
             "Awesome OS for S390 Bits": ["Not supported by a valid subscription."]}]}
```

* `GetPools(dictionary(string,variant))`: Returns a list of pools accessible by this system. 
  The `options` dictionary can contain those arguments:

  * `consumed`: list of pools from all consumed subscriptions only
  * `matches`: list of pools those names contains of the wanted string
  * `no_overlap`: list of pools that can cover the installed products. 
    The products that are not covered by any subscription yet.

  You can combine the arguments.

```python
>>> GetPools(no_overlap=true)
[{"subscription_name": "Multi-Attribute Stackable (4 cores)",
  "provides": ["Multi-Attribute Limited Product"],
  "sku":      "cores4-multiattr",
  "contract": 0,
  "account":  "12331131231", 
  "serial":   "8552108704959396720",
  "pool_id":  "8a882d8d5c2f9deb015c2f9f6e6403be",
  "provides_management": false,
  "active":    true,
  "quantity_used": 1,
  "service_level": "Premium",
  "service_type":  "Level 3",
  "status_details": "Subscription is current",
  "subscription_type": "Stackable",
  "starts":            "2017-05-21",
  "ends":              "2018-05-21",
  "system_type":       "Physical"},
 {"subscription_name": "Admin OS Server Bundled (2 Sockets, Standard Support)",
  "provides": ["Load Balancing Bits",
               "Awesome OS Server Bits",
               "Clustering Bits"],
  "sku":      "adminos-server-2-socket-std",
  "contract": 1,
  "account":  "12331131231", 
  "serial":   "4929383944640732124","
  "pool_id":  "8a882d8d5c2f9deb015c2f9f50b30159",
  "provides_management": true,
  "active":    true,
  "quantity_used": 1,
  "service_level": "Standard",
  "service_type":  "L1-L3",
  "status_details": "Subscription is current",
  "subscription_type": "Standard",
  "starts":            "2017-05-21",
  "ends":              "2018-05-21",
  "system_type":       "Physical"}
]

>>> GetPools(consumed=true,
             matches="Stackable")
[{"subscription_name": "Multi-Attribute Stackable (4 cores)",
  "provides": ["Multi-Attribute Limited Product"],
  "sku":      "cores4-multiattr",
  "contract": 0,
  "account":  "12331131231", 
  "serial":   "8552108704959396720",
  "pool_id":  "8a882d8d5c2f9deb015c2f9f6e6403be",
  "provides_management": false,
  "active":    true,
  "quantity_used": 1,
  "service_level": "Premium",
  "service_type":  "Level 3",
  "status_details": "Subscription is current",
  "subscription_type": "Stackable",
  "starts":            "2017-05-21",
  "ends":              "2018-05-21",
  "system_type":       "Physical"},
]
```

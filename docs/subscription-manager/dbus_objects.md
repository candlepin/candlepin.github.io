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

# Attach
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Attach`
* Bus path: `/com/redhat/RHSM1/Attach`

The Attach object provides an interface to attach subscriptions to the system.

## Methods
* `AutoAttach(string, dictionary(string, variant)`: Perform an auto-attach on
  the system.  A service level (or empty string for none) is provided as the
  first parameter and a dictionary of proxy options for the second.
* `PoolAttach(array(string), id, dictionary(string, variant)`: Attach
  specific pools to the system.  The first parameter is a list of pool IDs, the
  second a quantity, and the final parameter is a dictionary of proxy options.

# Products
* Bus name: `com.redhat.RHSM1`
* Interfaces: `com.redhat.RHSM1.Products`
* Bus path: `/com/redhat/RHSM1/Products`

The Products object provides an interface to list installed products.

## Methods
* `ListInstalledProducts(string, dictionary(string, variant))`: Return
  list of installed products. The argument order is: `filter, options dictionary`.
  The `filter` argument can be used to filter out some products from returned
  list of installed products. The options dictionary contains proxy options.
  This call returns the JSON list of installed products.

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
* `Register(string, string, string, dictionary(string, variant),
  dictionary(string, variant)`: Register a system via subscription-manager.  The
  argument order is `organization, username, password, options dictionary,
  connection options dictionary`.

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
  variant), dictionary(string, variant)`: Register a system using one or more
  activation keys.  The argument order is `organization, activation key list,
  options dictionary, connection options dictionary`. The options dictionary
  should only contain `name` and/or `force` since activation keys cannot be used
  with environments or existing consumer IDs.  The connection options dictionary
  can contain the same values as `Register`.  This call returns the JSON
  response body from the subscription management server.

---
layout: default
title: API
---
{% include toc.md %}

# API
Candlepin uses a RESTful api powered by [RESTEasy](http://www.jboss.org/resteasy/).
See [the glossary](glossary.html) for definitions of terms
used here. The data is returned in JSON objects unless noted below.
For information on using JSON in JAXB frameworks go [here](json_jaxb.html).

There are two "main" interfaces. One, the consumer, is a subset of the other,
which is the management. The consumer API represents the set of functions which
a client would need in order to consume entitlements from Candleping. The
management API is the complete set which would be used by a WebUI, Message Bus,
or other controller ofthe engine

## Consumer API
The Consumer API is a subset of the API which supports the lifecycle of the consumer. The basic flow of the API is:

1. *Register* : The client registers with candlepin. This call requires user
   credentials, and can include "facts" about the consumer. A successful
   registration creates a consumer in the candlepin system and generates an
   Identity Certificate which can be used for subsequent calls.
1. *List Pools* : The client can list the pools which the consumer can pull entitlements from.
1. *Bind* : Bind is the action of a consumer taking one entitlement from the
   pool. A Bind can be done based on a pool id, a product id, or based on a
   "best" match. The result of a successful bind is an entitlement certificate
   which can be stored.
1. *Monitor* : The client can poll candlepin to determine if the entitlement
   certificates which are stored locally are still accurate.
1. *Un-Bind* : The client can give an entitlement back to the pool.
1. *Un-Register* : The client can delete a consumer, giving all entitlements back to their pools.


### Methods
The actual methods for the above lifecycle are:

* *registerConsumer*: _Register an entitlement consumer._
  * params
     * _string_: userid
     * _string_: password,
     * _HardwareProfile_: hardwareProfile,
     * _InstalledProducts_: installedProducts
  * returns: Bundle

  ```
  {'facts': {'arch':'i386', 'cpu':'Intel'},
   'id': '1',
   'name': 'billybob',
   'type': {'id': '1', 'label': 'system'},
   'uuid': '9202406b-2bfd-4a5a-9ec4-44f9f6169d31'}
  ```

  Note: This will eventually be some sort of client id/certificate. That
  may be a attribute of the above struct, or something completely different ;->

   * RESTful representation: POST /consumer
       * params - Consumer
       * returns - Consumer
   * Note: At the moment, no struct is defined for hardware or product info.
   * Note: some ideas for [wiki:hardwareInfo]

 * *unregisterConsumer*: _Unregister an entitlement consumer._
   * params
      * _string_: consumer_uuid
   * returns: void
   * RESTful representation: DELETE /consumers/{cosumer_uuid}

 * *getCertificates*: Fetches a list of all certificates for a given consumer.
   Client tools can compare the result to what is present, discard certificates
   no longer required, add new, and leave the others unchanged. See also the
   *getCertificatesMetadata* call.
   * params:
      * _string_: consumerId
      * _serials_: Optional comma separated list of certificate serial numbers to fetch (assuming they are available to this consumer).
   * returns: List\<Certificate\>
   * RESTful representation: GET /consumers/{consumer_uuid}/certificates?serials=serial1,serial2,serial3

 * *getCertificateSerials*: Similar to _getCertificates_, except returns only
   serial numbers. Allows client tools to only fetch required certificates.
   * params:
      * _string_: consumerId
   * returns: List\<CertificateSerial\>
   * RESTful representation: GET /consumers/{consumer_uuid}/certificates/serials

 * *bind* **(OVERLOADED)**: _Consume an entitlement which (binds) consumerId with an entitlement._
   * params:
      * _string_: consumerId
      * _string_: (regnum | poolId | product OID) (optional) When not specified, picked by candlepin
   * returns: A List of Entitlement objects
   * RESTful representation: product POST /consumers/{consumer_uuid}/entitlements?product=[{product_id1,product_id2]} (array of productid strings)
   * RESTful representation (regnum): POST /consumers/{consumer_uuid}/entitlements?token={token}
   * RESTful representation (poolId): POST /consumers/{consumer_uuid}/entitlements?pool={pool_id}

 * *getEntitlements* : _Get a list of entitlements this consumer has._
   * params:
      * _string_: consumerId
      * _string_: productId (optional product filter)
   * returns: List\<Entitlement\>
   * RESTful representation: GET /consumers/{consumer_uuid}/entitlements?product={productId}

 * *unbind* **(OVERLOADED)** : _Unconsume an entitlement.  Put it back in the
   pool and removes associate between consumer and entitlement._
   * params:
      * _string_: consumerId
      * _List\<string\>_: serialNumbers (optional).  No serial number implies unbind all.
   * returns: void
   * RESTful representation: DEL /consumers/{consumer_uuid}/entitlements/{entitlement_id}  (preferred)
   * RESTful representation: DEL /consumers/{consumer_uuid}/entitlements  (deletes all entitlements)

 * *getEntitlementPools* : ''Get a list of entitlement pools appropriate for this consumer."
   * params:
      * _string_: consumerId
   * returns: List\<Pool\>
   * RESTful representation: GET /pools?consumer={consumer_uuid}

 * *ping* : _Report the status of the service._
    * params: None
    * returns: Boolean (for now, could also return api version, etc)
    * RESTful represenation: GET /status (not implemented yet)

### Data Structures
* *Pool*: Represents an entitlement pool that can be consumed from.

  ```
  {
    "id":"2",
    "active":"true",
    "startDate": "2007-07-13T00:00:00-04:00"
    "endDate": "2010-07-13T00:00:00-04:00",
    "quantity": "20000", # how many entitlements are in the pool
    "consumed": "20000", # how many entitlements are currently in use
    "productId": "33132",
    "productName": "Very Cool Product",
    "sourceEntitlement": null,
    "unlimited": false,
    "created": "2007-06-04T13:13:30.813+0000",
    "updated": "2010-06-04T13:13:30.813+0000",
  }
  ```

* *Entitlement*: Represents the consumption of a subscription

  ```
  {
    "id":"1",             # can be used for unbinding
    "isFree":"false",     # normally false, entitlements may be granted for free in some edge cases
    "pool": {}            # see Pool struct, represents the pool this entitlement was granted from
    "startDate":"2010-03-04T13:24:22.472-05:00"
  }
  ```

* *Consumer*

  ```
  {
      "type": {'label':"system"},
      "name":'billybob',
      "facts": {'arch':'i386', 'cpu':'Intel'},
  }
  ```

* *Certificate Serial* : Simple representation of a certificate serial number.
    * _serial_ : Certificate serial number.

  ```
    {'serial': 'MYSERIALNUMBER'}
  ```

* *Certificate* : May represent an entitlement or an identity certificate.
  * _serial_: Certificate serial number. (string)
  * _key_: PEM encoded certificate private key.
  * _cert_: PEM encoded certificate.
  * *NOTE:* The x509's DN contains the following data:
    subject:CN=\<consumer_name\>, UID=\<consumer_uuid\>, OU=\<owner_name\>
  * *NOTE:* For API calls that return only certificate metadata, the key and
    cert fields will not be present in the struct.

  ```
  {
    serial: "SERIALNUMBER",
    key:  "MIIEowIBAAKCAQEAowJvPbgiZtmyKvwSDhhouRwgBihOQ8P+Av3kn8I6H41FNTW4
           Soa1GfV/C84vS72MPC79ig0SxqUfKFT3e4Ria6MVdFB6B3nePF9Pcm9zMpXtgkuJ
           O2Mgr3eG7VdgEDXgtB2ZObc/lb4NaA4mc8Kj1r6Sj6WcZBUSviJYvLngPge4hRzU
           1H6+Uju1ZNvv4ElScVJMKgOBquL8EJIEmIIGP84IwQhk+mdArKl1Ch3FtadXJn6t
           SNQWkeYZ9OKHCW/McudKgnCV/v/xjnbqAbQ/tJqfHsRIqzb4BPaM+s+bHgpXh+Bz",
    cert: "MIIEowIBAAKCAQEAowJvPbgiZtmyKvwSDhhouRwgBihOQ8P+Av3kn8I6H41FNTW4
           Soa1GfV/C84vS72MPC79ig0SxqUfKFT3e4Ria6MVdFB6B3nePF9Pcm9zMpXtgkuJ
           O2Mgr3eG7VdgEDXgtB2ZObc/lb4NaA4mc8Kj1r6Sj6WcZBUSviJYvLngPge4hRzU
           1H6+Uju1ZNvv4ElScVJMKgOBquL8EJIEmIIGP84IwQhk+mdArKl1Ch3FtadXJn6t
           SNQWkeYZ9OKHCW/McudKgnCV/v/xjnbqAbQ/tJqfHsRIqzb4BPaM+s+bHgpXh+Bz"
  }
  ```

## Management API
This is the full API which is supported by the engine. You can generate a
realtime list by running `buildr clean test:ApiCrawlerTest`

### Admin Interfaces
 * GET /admin/init : Initialize sample data
 * POST /owners/{key}/users : Create a user for the owner.
 * GET /status : Returns true if the server is alive
 * PUT /owner/{id}/subscriptions : Call the refresh subscription logic on an owner

### ATOM Feeds
 * GET /atom : All events
 * GET /consumers/{dbid}/atom : All events for a consumer
 * GET /owners/{key}/atom : All events for an owner

### Consumers
 * GET  /consumers : Get a list of Consumers
 * POST /consumers/ : Create a Consumer
 * GET  /consumers/{uuid} : Get a single Consumer
 * PUT  /consumers/{uuid} : Update a consumer and its facts
 * DELETE  /consumers/{uuid} : Delete a Consumer
 * GET  /consumers/{uuid}/certificates : Get a Consumer's Entitlement Certificates
 * POST  /consumers/{uuid} : Regenerate a consumer's identity certificate
 * PUT  /consumers/{uuid}/certificates : Regenerate a consumer's entitlement certificates
   * query parameters:
     * entitlement: optional entitlement id. If provided, will only regenerate the certificates for this entitlement.
 * GET  /consumers/{uuid}/certificates/serials : Get a Consumer's Entitlement Certificate Serial Numbers
 * DELETE  /consumers/{uuid}/certificates/{serialid} : Delete an entitlement given a entitlement certificate
 * GET /consumers/uuid/entitlements : Get the entitlements or a consumer
 * POST /consumers/{uuid}/entitlements : Creates a new Entitlement for a Consumer
   * query parameters:
     * pool: The pool to create an entitlement for
     * token: A Reg Token to create an entitlement for
     * product: An array of Product IDs to create an entitlement for
     * quantity: The number of entitlements to create
     * email: The email to send confirmation to if registering by token
     * email_locale: The locale of the email.
 * DELETE /consumers/{uuid}/entitlements/{dbid} : Deletes a specific entitlement
 * GET /cusomers/{uuid}/export : Create an export file for the consumer

### Consumer Types
 * GET /consumertypes : Get all the consumer types.
 * POST /consumertypes : Create a new consumer type
 * PUT /consumertypes/{id} : Create a new consumer type for a given id
 * DELE /consumertypes/{id} : Delete a consumer type

### Entitlements
 * GET /entitlements : Get all entitlements
 * GET /entitlements/{dbid} : Get a specific entitlement
 * DELETE /entitlements/{dbid} : Delete an entitlement
 * GET /entitlements/consumer/{consumer_uuid}/product/{product_id} : Get an entitlement for a given product

### Owners
 * GET /owners : Get all owners
 * GET /owners/{key} : Get a specific owner
 * POST /owners : Create a new owner
 * PUT /owners/{key} : update an owner
 * DELETE /owners/{key} : Delete an owner
 * GET /owners/{key}/users : Get the list of users for an owner
 * POST /owners/{key}/import : Load en extract file for the owner
 * GET /owners/{key}/entitlements : Get the entitlements for an owner
 * GET /owners/{key}/pools : Get the pools for an owner
 * GET /owners/{key}/subscriptions : Get the subscriptions for an owner
 * PUT /owners/{key}/subscriptions : Refresh the subscriptions for an owner.
   * query params:
     * auto_create_owner = true if the user should be created if not present.
 * GET /owners/{key}/info : Get summary info about an owner, including consumer
   counts by type, and consumed subscription counts by consumer type.

### Pools
 * GET /pools : get a list of pools
   * query params:
     * owner = owner id
     * product = product id
     * consumer = consumer id
     * listall = use with consumerUuid to list all pools for the consumer's owner
     * activeon = date string to list when the pools are active on. format is "yyyyMMdd"
 * GET /pools/{id} : get a pool based on a given ID.
 * POST /pools : creates a new pool.
 * DELETE /pools/{id} : delete an existing pool

### Products
If the product adapater supports them:

 * GET /products : Get all products
 * GET /products/{dbid} : Get a specific product
 * GET /products/{product_uuid}/certificate : Get a product certificate
 * DELETE /products/{product_uuid} : delete a product
 * POST /products : Create a new product
 * POST /products/{product_uuid}/content/{content_id} Associate a specified content object with the product
   * query params:
     * enabled = true if the content is enabled by default.

### Rules
 * POST /rules/: Upload a new set of entitlement rules (base 64 encoded string)
 * GET /rules/: Get the set of Rules currently in use (base 64 encoded string)

### Subscriptions
 * GET /subscriptions : get all the subscriptions
 * DELETE /subscritptions/{id} : delete a subscription

### Subscription Tokens
 * GET /subscriptiontokens : get all the subscriptiontoken
 * POST /subscriptiontokens : create a subscriptiontoken
 * DELETE /subscriptiontokens/{id} : delete a subscriptiontoken

### Events
 * GET /events : list all events
 * GET /events/{event_uuid} : Get a specific event

## Generate the Latest Version of the API
To auto generate a list from the source code, run `buildr candlepin:apicrawl`.

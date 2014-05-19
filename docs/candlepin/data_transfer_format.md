---
title: Data Transfer
---
{% include toc.md %}

# Data Transfer Format for Populating On-premise Candlepin

## Goals
 * allow for easy disconnected/connected loading of product and entitlement info into an on-premise candlepin from hosted candlepin
 * allow for multiple hosted consumers to map each into their own owner in a single on-premise candlepin
 * reuse as much of the existing product/entitlement data as possible
   * json data from candlepin api
   * x509 certs included for use as a consumer of the upstream candlepin

## Initial Scope
We will begin with the disconnected case. Assuming that all the data we need is
located in some file or set of files on the candlepin server, a candlepin admin
should be able to run a command to import that data into candlepin (probably
posting to candlepin's rest api).

## Information we need
 * consumer types
   * will come from json.
 * rules
   * use the existing rule upload stuff
 * initial owner/user
   * probably from a setup util
 * products
   * content sets
   * product hierarchy
 * subscriptions (comes from an entitlement granted to the cp instance)
 * upstream consumer information (uuid)

### Products
Required data:

 * id
 * name
 * variant
 * arch
 * version
 * product attributes
 * product multiplier
 * content sets:
  * type
  * name
  * label
  * vendor
  * content url
  * gpg url

### Subscriptions
From an entitlement we can get the following subscription data:

 * product ids (both the 'primary' product and the rest)
 * upstream pool id
 * start date
 * end date
 * quantity
 * contract number

Subscriptions also have support for attributes, but we have none defined, and do not use them.

## Data Bundles
Assumption: there is an easy way to tar up all data relevant to a particular candlepin consumer.

Inside the tarball will be:

```text
/meta.json
/consumer.json
/entitlements/
/entitlement_certificates/
/products/
/consumer_types/
/rules/
```

The data inside the tarball will always be a full snapshot of the latest information.

This tarball will come with a matching detached cryptographic signature, signed by red hat/the upstream candlepin.

### meta.json
A json file containing metainformation about the bundle. A version string would be a good starter for this.

### consumer.json
A json file containing the upstream consumer uuid which is entitled to these subscriptions.

### entitlements
json file named by entitlement id containing entitlement information

### entitlement_certificates
PEM encoded key/cert pairs of all entitlement certs this candlepin has access to, named by certificate serial

### products
PEM encoded certs for all products for which this candlepin has access to, as granted by its entitlements. named by product id, and a matching json file

### consumer types
One json file per consumer type, named after the type. Each file will probably only ever contain a single field.

### rules
One rules.js file.

## Importing
We can provide a REST api that, when the tarball and signature is posted to it, will:

 * verify the signature
 * open the tarball
 * read the metainfo, and verify it knows how to handle the version
 * read the consumer.json file, and map this back to an owner.
   * this upstream consumer to owner mapping will have to be done in another step, probably some form of registration.
 * replace the existing rules file with the new one
 * list all consumer types on candlepin
   * remove from the db any not in the consumer types dir, provided the type is not used by any existing consumers
   * add any types to the db in the dir but not in candlepin
 * for each product:
   * load the product json, store in the db
 * for each entitlement:
   * create a matching 'downstream' subscription object (that the local candlepin will use to distribute entitlements)
   * map to the imported products
 * trigger a pool refresh on the matching owner
 * for each entitlement certificate:
   * read the cert's subjectDN and extract the subscription id from the CN field
   * create a new EntitlementCertificate object for each cert
     * associate cert to Subscription

### Events to emit on import
 * consumer type added/updated/removed
 * rules updated
 * product updated/added/removed
 * subscription updated/added/removed
 * entitlement set updated for owner (will require some extension to the existing event model)

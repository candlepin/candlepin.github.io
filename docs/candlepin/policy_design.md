---
categories: design
title: Policy Design
---
{% include toc.md %}

# Facts
Consumers will have *facts*, provided when the consumer registers and requests
their UUID. These will contain all necessary data about that type of consumer,
CPU cores being the most common example used initially. This implies the
consumer client side code (potentially rhn_register) implicitly knows what
information it must gather and send to the server, although the server may not
use it all.

These attributes will likely need to be updated periodically.

# Attributes
* Attributes can be thought of as a hint on some restriction on the usage of an
  entitlement. 
* They will not actually contain the logic on how to enforce the Attribute, but
  basically just act as a constant the policy rules can look for, and a little
  metadata that may be required to enforce. 
* Attributes can be affiliated with a given product in the product database, or
  they can be affiliated with entitlements granted within a particular
  customer's order/certificate.
* All Attributes must pass for the entitlement to be granted to a consumer. Not
  sure if this statement will stand the test of time, may be some issues here
  with "enabling" attributes vs "restricting" attributes and knowing when to
  grant/not grant based on the outcome of multiple checks. Will see how it
  goes.
* Attributes can be associated with a product, or more commonly with an order
  of that product contained in the cert. For us, this probably means they'll be
  associated with entitlement pools in the database.
  * If the same Attribute is found on both the product and the entitlement
    pool, the entitlement pool's version can be assumed as the authoritative
    one to check.

## Attribute Examples
* *cpu-count NUM_CPUS*
  * Some kind of restriction on the number of CPUs.
* *cpu-cores NUM_CPUS*
  * Some kind of restriction on the number of CPU cores.
* *free-children NUM_CHILDREN*
  * Indicates NUM_CHILDREN child consumers can be entitled to this product as
    well. (essentially for free, or rather included in the parent consumer's
    receiving the entitlement)
  * I.e. if you have 10 entitlements to rhel-server with 5 max-free-children,
    each physical system using an entitlement can have up to 5 guests also
    subscribed to rhel-server without consuming one of the original 10
    entitlements.
  * If a child requested this entitlement, the parent already had 5 children
    using rhel-server, entitlement would then consume one of the remaining 10
    physical entitlements. (or fail if they were exhausted)
  * This is one of the more tricky ones to represent in rules metadata as it's
    not a check against this consumer, but rather against the parent, and even
    then involves a check for how many of the parents children already have
    this product.
* *max-guests*
  * Probably RHEL specific, a limitation on the number of virt guests allowed
    on the host.
  * Note difference with free-children entitlements to a product.
* *max-version VERSION*
  * Max version of the product this entitlement is valid for.
* *min-version VERSION*
* *max-ram RAM*
  * Entitlement can only be consumed by a system with less than or equal to
    some amount of memory.
* *consumer-type TYPE*
  * Limit this entitlement to only be given to consumers of a particular type.
  * Could be a more flexible than the max-children idea above.
* *architecture ARCH*
  * Entitlement only valid for given architecture.
  * May need to specify multiple, which could be complicated if we assume all
    Attribute tests must pass for a given consumer to be entitled.
* *flex-consumption FLEX*
  * Allow entitlement even if over assigned quantity by some amount. (%age,
    actual number, etc.)
  * Ideally this would also know to warn if over quantity but granted by virtue
    of being within the flex range.
  * Is this a better fit if moved onto attributes themselves? I.e. every
    attribute can specify a flex range in which the entitlement will still be
    granted, but with a warning.
   

# Policy
* Policy maps Attributes to the checks run against the attributes on a consumer
  to determine if they can consume this entitlement or not. 
* Policy will also define the flexibility around use of entitlements, and what
  leeway we grant a customer if they run over. 
* Policy will be pluggable, and can be updated in the future to accommodate new
  Attributes, or just new ways of enforcing the existing ones.
* The actual implementation of the policy will also need to be pluggable.
  Initial implementation will probably be a homebrew mix of YAML/json and a
  custom rule parser. In the future we may want to implement a more robust
  rules engine.
* Policy will assume an implicit quantity check.
  * Results of this may be affected by the presence of a flex attribute.

## Javascript Policy Engine
Proposed plan for leveraging the scripting language additions to Java 6.

* Assume a push model as with certificate uploads, and expose a REST method
  which allows for the upload of new rules.
  * We're assuming these rules are one day distributed from some centralized
    location.
  * Assume whatever products are using Candlepin will be responsible for
    scheduling these updates.
    * Alternatively we can provide a small script that can be run via cron to
      fetch new rules.
* Rules will be distributed and interpreted as Javascript.
* Design some restrictive read-only objects inside the Candlepin Java code
  allowing access to objects such as the consumer (it's type, facts,
  entitlements, parent) and the product (it's type, attributes, etc).
  * Make these objects available to the Javascript engine.
* In the future, the rules will be verified for a valid GPG signature.

Sample Javascript, product specific checks are specified by a function matching the product label:

```javascript
function virtualization_host() {
  // Only physical servers can consume, and they must have no guests currently:
  if (consumer.type == "server" && parseInt(consumer.fact["guest_count"]) == 0) {
    return true;
  }
  // TODO: How to specify the post-entitlement actions, in this case something like:
  //   create-consumer-pool virt_guest 5
}

function rhel_5_server() {
  // Guests can always get this if their parent has an entitlement
  if (consumer.type == "virt_guest" && consumer.parent.has_entitlement("virtualization_host")) {
    return true;
  }

  // Physical servers must have less than 8 cores, order defined this limitation
  if (consumer.type == "server" &&  parseInt(consumer.fact["cpu_cores"]) <= order.attribute['max_cpus']) {
    return true;
  }

  return false;
}
```

# Outstanding Issues
* If a customer has multiple types of an entitlement for one product, when a consumer requests to be entitled, how do we know which type of entitlement to consume?

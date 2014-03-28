---
layout: default
categories: design
title: Multi-Version Product Design
---
# Multi-Version Products Design
Soon it will be possible to have multiple versions of the same product installed on a system.

## Issues
1. Subscription Manager stores product certificates as [productid].pem, which
   obviously clashes if there are multiple versions of the same product
   installed.
1. Subscription Manager UI displays installed product version. Will this work
   ok if there were multiple certificates?
1. Subscription Manager does not report the installed version. It is populated
   on the server automatically by querying the product service and using the
   version it reports. (totally broken and needs to be fixed)
1. Compliance Checking: If I have multiple versions of a product installed,
   what is required for me to be "green"?

## Design
1. As a user, I would like to be able to install multiple versions of the same
   product on one system. 
   * Modify productid.py updateInstalled method to not just use PRODUCTID.pem
     as the filename. (perhaps productid-version.pem)
   * Refactor so the `ProductDirectory` object is responsible for determining
     where to write a cert and with what filename. (rather than using
     cert.write(filename)
   * Prevent duplicates from getting written. (probably helped by pushing the
     write logic into `ProductDirectory`)
   * Handle backward compatability, likely by having `ProductDirectory` do a
     quick check on load for old filenames and if any are found, write them in
     the new fashion.
   * Examine usage of certificate directory findByProduct vs findAllByProduct.
1. As a user, I would like to be able to see the various product versions
installed in GUI and CLI.
   * GUI handles this ok right now as far as I can tell.
   * CLI list --installed is only showing one. Needs a small update to be aware
     there could be multiple versions.
1. As an engineer, I would like subscription manager to send installed product
versions to Candlepin.
   * Client should send up the versions along with installed products.
     Currently only one of them will be written to the installed products cache
     and sent to server. (/var/lib/rhsm/cache/installed_products.json) It is
     however sent as a list of hashes, so API should not need to change.
   * Handle changes to installed products. (i.e. a new version of an existing
     product is added or removed, we must know something has changed in the
     cache and send to the server.
1. As an engineer, I would like Candlepin to accept installed product versions
for consumers.
   * Currently there is a version stored in the installed product data in
     Candlepin, but it is not sent by the client. Candlepin is calling the
     product adapter and using whatever version appears on the product data
     that is returned, which is likely unusable.
   * What should happen to existing versions in the database?
     * Could clear them an upgrade script. A little risky in that if it were
       run on a server that was already accepting versions we would wipe them.
       (would this happen? you should be upgrading your db before deploying a
       new version of cp that was accepting versions)
     * Could just let clients start reporting them and leave anything old.
   * Test both new clients talking to older Candlepin (suspect Candlepin will
     just clobber the incoming version but nothing we can do about that now,
     just need to be sure it doesn't error out), and old clients talking to new
     Candlepin (should not store any product version).
1. As a user, I would like red/yellow/green status correctly defined when I
have multiple versions of one product installed.
   * TBD: This is mostly pending feedback on what exactly the requirements are.
     Until then there's not much we can do.
   * Key question is whether or not multiple concurrent versions requires
     multiple entitlements.

---
categories: design
title: Per-Org Products
---
{% include toc.md %}

# Overview

Candlepin 2.0 will involve a massive data model change affecting how products, subscriptions, and pools are stored. Previously, products were a global entity across the entire Candlepin server, there would be only one record for any given product ID. Custom products would have to be created in this global namespace, which is a bit odd and not desirable in a multi-tenant scenario. On import, one tenant could trigger certificate regenerations for another tenant if an updated version of the product came in.

## High Level Changes

 1. A large upgrade process is provided which will migrate all existing data to each org that uses it.
 1. Product data will now always be cached in Candlepin's database, it is no longer queried from service adapters in production.
 1. Each org which uses a product will receive it's own copy of that product. A product will exist only once in an org.
 1. Subscriptions as a model object will no longer be in Candlepin's database. They are used only as transient objects during import.
 1. Manifest import and refresh pools have been largely combined into one operation. Importing will bring in both the customers latest subscriptions and product data, not just one or the other.
 1. Custom subscriptions are no longer necessary, you can create custom pools directly for custom content you wish to expose.
 1. Client facing API calls remain unchanged as does their JSON response, to keep clients in the wild functioning properly. Some API calls used only by portal/Satellite may need updating.

### Benefits

 1. Custom content can be created only for the org which wishes to use it.
 1. Dramatic reduction in data duplication in the candlepin database. (no more copying data from subscription to pool, and copying all product data onto every pool that uses it)
 1. One org importing a manifest can no longer affect, or trigger certificiate regenerations, in other orgs.
 1. Eliminates issues in portal where subscription data might be out of sync with product service changes, leading to very strange bugs and a requirement to refresh pools for the customer. Now, all subscription and product data will be pulled during the import.
 1. Gained referential integrity for pools and products.

## Database Upgrade

To facilitate storing products and product content in a per-org manner, several changes to the database and object model have been made. While the normal deployment process will make these changes automatically, any existing tooling and/or scripts will need to be updated in accordance with the changes listed below.

 1. Several per-org versions of existing tables are created. These tables are created with a "cpo\_" prefix rather than the "cp\_" prefix. The new tables also somewhat standardize table name pluralization and column name underscore usage. Affected tables include: *cp\_activation\_key\_product, cp\_branding, cp\_content, cp\_content\_modified\_products, cp\_env\_content, cp\_installed\_products, cp\_pool\_branding, cp\_pool\_products, cp\_pool\_source\_sub, cp\_product\_attribute, cp\_product\_certificate, and cpo\_product
 1. *cp\_pool* is updated with several new fields to hold information previously owned by subscriptions.
 1. For each organization, existing products referenced by pools or subscriptions owned by the current organization are copied to the new *cpo\_products* table with a reference to the new org and a new UUID. Any reference within the database to a product is made using the UUID with enforced referential integrity.
 1. Any per-product data are then copied to the new per-org tables for each product in the current organization. This currently includes product attributes and content, certificates and activation keys.
 1. Next, per-org pool data, such as branding, are migrated.
 1. Finally, data which were previously only associated with subscriptions are migrated to the new fields in *cp\_pool*. This includes upstream object references, subscription certificates and CDN details.

At the time of writing, the deprecated tables, and any data contained therein, are left as-is in the database. While these tables will be entirely unused, they will be retained for a period to ensure a failed or incomplete migration can be manually fixed or completed if necessary. These tables will eventually be dropped in a future update.


# Changes for Customer Portal

 1. A pre-upgrade API call is provided that will populate the currently empty and unused cp_product and cp_content tables in Candlepin.
   * This iterates all known product IDs and their content, and stores them directly in Candlepin's database. (these tables exist today but are empty in production) This will be to seed the data so we can re-use the main upgrade we developed for Satellite here as well, which will copy each of these products into every org which has pools that use them.
   * Will need to coordinate closely to figure out how best to roll this out.
 1. We would like to test the database upgrade against a copy of the production database sooner rather than later as it's difficult for us to anticipate what will happen with full mysql prod data.
 1. API call to refresh pools may change. (TBD)
 1. Refresh pools will now pull latest subscription *and* product data in for the org. Product service adapter memcached layer may be able to go away if you wish.


# Changes for Satellite

 1. API calls for creating custom products have changed to owner specific URLs. (i.e. ```POST /owners/{key}/products``` instead of ```POST /products```)
 1. You no longer create a custom "subscription" for custom content and then call refresh pools, you can just create the pool you want directly. (```POST /owners/{key}/pools```)
 1. Refresh pools API is no longer relevant in Satellite and may not even be usable. Usage of it will need to be removed.
 1. Retreiving product certificates should be done with an org-specific call (```GET owners/{key}/products/{product_id}/certificate``` instead of ```GET products/{pid}/certificate```). Omitting the owner may not pull the proper certificate and may eventually be disabled entirely.


# Migrating to Candlepin 2.0

Migrating to Candlepin 2.0 from an earlier version is similar to standard upgrade done with the
included deployment scripts. Though, due to the extensive nature of the changes made in this
version, it is highly recommended to use additional tooling to ensure the upgrade and migration goes
as smoothly as possible.

To begin, make sure the local database is populated by running the "populate DB" task. This is only
required in hosted environments and will no-op in standalone environments, so it's safe to do if
you're unsure whether or not it's necessary.

```curl -k -u admin:admin "https://localhost:8443/candlepin/admin/pophosteddb"```

Wait a bit for the task to finish (or periodically check the job status via /jobs/{job_id}),
then take a snapshot of the environment with the [cmv](cmv.html) utility.

```
cd ~/devel/candlepin/server
./bin/cmv snapshot
```

Once the snapshot is finished, a normal upgrade can be done via the deploy script.

```./bin/deploy```


Finally, the migration can be verified with the cmv tool. While cmv can be run without any
parameters, there are several expected changes/warnings that can be safely ignored (more on this
below). To exclude all the expected warnings, the following command can be used:

```./bin/cmv --exclude orgs.pools.productAttributes.created --exclude orgs.pools.productAttributes.updated --exclude orgs.pools.derivedProductAttributes.created --exclude orgs.pools.derivedProductAttributes.updated --exclude orgs.pools.derivedProduct --exclude orgs.pools.upstreamPoolId --exclude orgs.pools.upstreamEntitlementId --exclude orgs.pools.upstreamConsumerId --exclude orgs.pools.cdn --exclude orgs.pools.product --exclude orgs.pools.providedProducts.id --exclude orgs.pools.providedProducts.created --exclude orgs.pools.providedProducts.updated --exclude orgs.pools.derivedProvidedProducts.id --exclude orgs.pools.derivedProvidedProducts.created --exclude orgs.pools.derivedProvidedProducts.updated --exclude orgs.pools.productAttributes.id --exclude orgs.pools.productAttributes.productId --exclude orgs.pools.derivedProductAttributes.id --exclude orgs.pools.derivedProductAttributes.productId --exclude orgs.products.href --exclude orgs.products.owner --exclude orgs.products.uuid --exclude orgs.products.productContent.content.uuid --exclude orgs.products.productContent.content.owner verify```

With this command, the verification should complete without any errors or warnings. If so, the
migration was completed successfully. Otherwise, steps may be necessary to manually complete the
migration, or it may be necessary to roll back and try again.



## Expected CMV Warnings

As noted above, there are several expected changes that will show up in a vanilla cmv verify during
migration to Candlepin 2.0. Most are related to minor changes in the JSON returned by API calls,
while a few others relate to precision issues with the migration to new database tables.

- orgs.pools.productAttributes.created
- orgs.pools.productAttributes.updated
- orgs.pools.derivedProductAttributes.created
- orgs.pools.derivedProductAttributes.updated

Dates are off by a few seconds due to a loss of precision between the DB and the migration tool

- orgs.pools.derivedProduct
- orgs.pools.upstreamPoolId
- orgs.pools.upstreamEntitlementId
- orgs.pools.upstreamConsumerId
- orgs.pools.cdn

These are new fields migrated from the old subscription model object; they will not exist in the
snapshot data

- orgs.pools.product

Pools now maintain a reference to the product, rather than just the product ID. As such, this field
will not exist in the snapshot data

- orgs.pools.providedProducts.id
- orgs.pools.providedProducts.created
- orgs.pools.providedProducts.updated
- orgs.pools.derivedProvidedProducts.id
- orgs.pools.derivedProvidedProducts.created
- orgs.pools.derivedProvidedProducts.updated

The provided products collections on a pool is now maintained by links to actual product references,
eliminating the need for a special object and its id, created and updated fields

- orgs.pools.productAttributes.id
- orgs.pools.productAttributes.productId
- orgs.pools.derivedProductAttributes.id
- orgs.pools.derivedProductAttributes.productId

Like the provided products field, product attributes on a pool is provided directly, rather than
through a secondary/join object. The id and productId fields will no longer be present as a result.

- orgs.products.href
- orgs.products.owner
- orgs.products.uuid
- orgs.products.productContent.content.uuid
- orgs.products.productContent.content.owner

Products and Content are now per-org, and now require a reference to their owner (organization), and
a new uuid field. These won't exist in the snapshot data. Additionally, the Product's href field now
includes the owner information.

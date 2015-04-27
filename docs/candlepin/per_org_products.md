---
categories: design
title: Per-Org Products
---
{% include toc.md %}

# Overview

Candlepin 1.0 will involve a massive data model change affecting how products, subscriptions, and pools are stored. Previously, products were a global entity across the entire Candlepin server, there would be only one record for any given product ID. Custom products would have to be created in this global namespace, which is a bit odd and not desirable in a multi-tenant scenario. On import, one tenant could trigger certificate regenerations for another tenant if an updated version of the product came in.

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

 TODO: Outline the exact steps the database upgrade will perform.


# Changes for Customer Portal

 1. A pre-upgrade process will be provided which pulls down a single copy of all products into the Candlepin database tables which already exist, but are empty today in hosted. This will be to seed the data so we can re-use the main upgrade we developed for Satellite here as well, which will copy each of these products into every org which has pools that use them.
 1. We would like to test the database upgrade against a copy of the production database sooner rather than later as it's difficult for us to anticipate what will happen with full mysql prod data.
 1. API call to refresh pools may change. (TBD)
 1. Refresh pools will now pull latest subscription *and* product data in for the org. Product service adapter memcached layer may be able to go away if you wish.
 1.


# Changes for Satellite

 1. API calls for creating custom products have changed to owner specific URLs. (i.e. POST /owners/{key}/products instead of POST /products)
 1. You no longer create a custom "subscription" for custom content and then call refresh pools, you can just create the pool you want directly. (POST /owners/{key}/pools)
 1. Refresh pools API is no longer relevant in Satellite and may not even be usable. Usage of it will need to be removed.


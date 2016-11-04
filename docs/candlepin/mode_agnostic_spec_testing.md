---
title: Mode agnostic spec testing
---
{% include toc.md %}

Candlepin can be run in two modes, Standalone and Hosted, and it is important that all spec tests pass in both modes. The intent of this page is to help Candlepin developers write and support spec tests in a mode agnostic manner, and to list some useful tips for testing in either modes.

## Problem
One of the ways that the two modes differ is in the manner by which pools are created.

* In Hosted mode, pools are created by the refresh pools operation, which relies on an upstream subsciption source.
* In Standalone mode, manifests have all the information required to create the subscriptions within candlepin, and the manifest import operation is used to create subscriptions in Candlepin.
* These subscriptions are then used to create the appropriate pools in both the modes.
* Since Candlepin 2.0 we no longer persist the subscriptions, only the pools that are created from them in either of the two modes.
* In Hosted mode, a refresh pools operation ensures the pools are synced up with the upstream subscription source, and in the absence of any subscriptions, removes the pools & entitlements of an owner.

## Solution
* For the sole purpose of supporting spec tests in hosted mode, we have introduced an upstream subscription source `'hostedtest'`
* All of the java source code that is added to support this and only this use case is added in the package path `org.candlepin.hostedtest`
* Currently, this is an in-memory collection of the subscriptions and supporting data ( products , owners, etc ) needed to create the pools after a pool refresh.
* There is a rest API @ `'candlepin/hostedtest/subscriptions'` and a corresponding ruby client provided to the tests, that are responsible to create their own test data by using appropriate API calls.
* we exclude all source code in the path `org.candlepin.hostedtest` from the candlepin.war unless explicitly specified by a developer

## How to test in hosted mode

* The most convinient way to deploy candlepin in hosted mode is to simply use the deploy script:

  ```console
  $ ./server/bin/deploy -Ha
  ```

* Which auto-generates the candlepin.conf with the following content ( it overrides whatever is specified in custom.yaml ):

  ```text
  candlepin.standalone=false
  module.config.hosted.configuration.module=org.candlepin.hostedtest.AdapterOverrideModule
  ```

  * The first line ensures we deploy candlepin in hosted mode and the second line initializes, injects and overrides the Subscription Adapter and the supporting Restful Resource.


* And builds the candlepin war with the hostedtest resources included:

  ```console
  $ buildr clean package test=no hostedtest=yes
  ```

* In order to revert to testing in standalone mode, It is recommended to always have this line in custom.yaml:

  ```text
  candlepin.standalone=true
  ```
so that we can revert back to hosted mode by :

  ```console
  $ ./server/bin/deploy -a
  ```

* Note: Hosted spec tests do not run successfully in parallel mode. Please run them only in serial mode!

## How to create pools in a mode agnostic manner
The server/client/ruby/hostedtest_api.rb utility has the following methods to help developers spec test in a mode agnostic manner:

* ensure_hostedtest_resource:
  * if we are in hosted mode, ensures the hosted test resource is available, else throws a useful error message
* create_pool_and_subscription:
  * create upstream subscription and refresh pools if running in hosted mode, create pool directly otherwise.
  * always returns the master pool created.
* delete_pool_and_subscription:
  * if we are running in hosted mode, delete the upstream subscription and refresh pools, otherwise simply delete the pool
* refresh_upstream_subscription:
  * This method is used when we need to update the dependent entities of a upstream subscription or pool. Simply fetching and updating the subscription forces a re-resolve of products, owners, etc.
* get_pool_or_subscription:
  * This method is used when we need to update the upstream subscription's details. First we fetch the upstrean pool ( if standalone mode ) or subscription ( if hosted mode ) using get_pool_or_subscription(pool) and then use update_pool_or_subscription to update the upstream entity.
  * input is always a pool, but the out may be either a subscription or a pool
* update_pool_or_subscription:
  * This method is used when we need to update the upstream subscription's details. First we fetch the upstrean pool ( if standalone mode ) or subscription ( if hosted mode ) using get_pool_or_subscription(pool) and then use update_pool_or_subscription to update the upstream entity.
  * input may be either a subscription or a pool, and there is no output
* cleanup_subscriptions:
  * used to clean up subscriptions at the end of each test run

---
title: Bind Operation Dependencies
---
{% include toc.md %}

## Bind time operation dependencies

 * Source: <a download="master_bind_dependencies_2.0.29.graphml" href="{{ site.baseurl }}/yed_artifacts/master_bind_dependencies_2.0.29.graphml" title="master_bind_dependencies_src">master_bind_dependencies_2.0.29.graphml</a>
 * Note: This document is true as of version 2.0.29
![]({{ site.baseurl }}/images/master_bind_dependencies_2.0.29.jpg){:.center-block}

## Dependencies Description
 * ONE: We need to to lock pools before the entitlements are persisted as they hold references to the pools.
 * TWO: We need the entitlement id to create the entitlement derived pool, hence we persist the entitlement before we do that.
 * THREE: Decrementing any pool's quantity may cause us to revoke excess entitlements.
 * FOUR: Entitlement Id is needed in the certificate as it is used in the DN part of the cert
 * FIVE, SIX, SEVEN: All consumer's non read operations need to be complete before we compute it's compliance

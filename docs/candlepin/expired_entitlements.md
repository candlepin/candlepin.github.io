---
title: Expired Entitlements
---
{% include toc.md %}

# Expired Entitlements

## Candlepin
Candlepin does not actively look for expired entitlements to revoke. We rely on
SSL to handle the verification that the certificate is still valid. (the CDN
should do this) 

Candlepin does however check for expired subscriptions during a refresh pools
operation for an organization. If any are found they (and their outstanding
entitlements) will be cleaned up.

This implies that at any given point in time, when a system requests it's
certificates it should have to perform a sync, it could see expired
certificates if a refresh pools has not yet been run for that org.

## Subscription Manager
As certs expire they will stop working against the CDN.

All certlib updates check for expired certificates at the end, and if any are
found they are deleted. As such, actually seeing "Expired" in the client will
be relatively rare, as any expired certs will be removed relatively quickly.

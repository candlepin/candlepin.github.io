---
categories: design
title: Reports
---
{% include toc.md %}

# Reports

As Gutterball is under heavy design and only in the very earliest stages of development, reporting does not yet exist. However the following reports are our target for implementation:


## System Entitlement Status

### Current system status

Based on existing SAM/Splice functionality.

| Hostname | UUID | Entitlement Status | Satellite Server | Organization | Last Check-in |

### Enhanced SA focused system status

| Hostname | UUID | Entitlement Status | Satellite Server | Organization | Last Check-in | Sockets | Cores |

### Subscriptions per host at a point in time

Each host would have one row per subscription.

Product Name would be the canonical name of the subscription, e.g. Red Hat  Enterprise Linux Service Level Premium for 4 sockets.

| Hostname | Quantity | Sockets | Contract Number | Start Date | End Date | Product Name |


## Organization Pools / Entitlements

### All Entitlements for org at a point in time

| Time | Entitlement ID | Quantity | Pool ID | Subscription Name | Product Name | Start Date | End Date |

### All Pools for org at a point in time

Need to watch out for how to report on sub-pools for guests, as well as stack sub-pools which are not tied to any one subscription.

| Time | Pool ID | Quantity Used | Quantity Available | Source Subscription/Stack Name | Product Name | Start Date | End Date |

### All Available Pools for org at a point in time:

| Time | Pool ID | Quantity Available | Source Subscription/Stack Name | Product Name | Derived Product Name |


## Users and Orgs

Issue here, we do not maintain user data, if we need these events, something else has to start sending them.

### User count at a point in time

| Time | User Count |

### User count at a point in time per org

| Time | Org | User Count |

### Org count at a point in time

| Time | Org Count |

### New users per time period


### Count of Consumers registered by a user at a point in time

| Time | Username | Count of Consumers Registered |

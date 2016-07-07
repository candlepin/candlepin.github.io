---
title: Candlepin 2.0 Product Versioning
---
{% include toc.md %}


# Overview
As briefly mentioned in the Candlepin 2.0 migration document, Candlepin 2.0 introduces per-org products and
content. Since many organizations tend to share product information, we quickly found that storing duplicated
product details grew our databases to unreasonable sizes far too quickly. To address this concern, we designed
and implemented shared product instances to de-duplicate product details that were identical between
organizations.

It should be noted that though this document focuses entirely on *product* versioning, the same design has
been applied to content entities as well.


# Versioning Design
The high-level explanation of versioning is fairly simple. Much like the naive implementation of
per-org products, we keep record of each distinct version of a given product, so long as at least one
organization is using it. A product is considered distinct from another if any component of the data differs
between the two; ignoring internal bookkeeping fields such as the database ID. This includes sub-objects like
product attributes and content, and their fields as well. These fields are combined to create a single,
identifiable product version.

When a product is first introduced to Candlepin, either through a manifest import, pool refresh or custom-made
via API, Candlepin creates a single instance of it for the organization that triggered the creation. When
another product is created, Candlepin will check if the given version of that product already exists for
another organization. If that version already exists, the new instance will be discarded and the organization
will be mapped to the existing version already in the Candlepin database. Otherwise, if it does not already
exist, a new instance will be created as normal.

![]({{ site.baseurl }}/images/versioning_creation.png)

Similarly, when an organization updates a product, the same version check is made. If the update would change
the product to a version Candlepin is already maintaining, the organization's existing product will be
silently discarded and they will be mapped to the existing version instead.

![]({{ site.baseurl }}/images/versioning_convergence.png)

However, if the update would result in a new version of the product, things get a bit more complex. First,
Candlepin checks how many organizations are using the product being updated. If that organization is the only
one using it, the product will be updated in place. But if multiple organizations are using the product, it is
forked into two entities, the organization performing the update is mapped to one, and the other organizations
to the other. Then, the update is performed for the organization as if it were an in-place update.

![]({{ site.baseurl }}/images/versioning_divergence.png)

Product deletion is handled in a similar manner. When an organization deletes a product, Candlepin checks the
number of organizations using that version of the product. If there are many organizations, the mapping is
simply updated to remove the organization that requested the deletion. Otherwise, if the organization
requesting the delete is the sole owner, the product is deleted from the database entirely.

![]({{ site.baseurl }}/images/versioning_deletion.png)

The convergent and divergent behavior of the CRUD operations allows Candlepin to reduce the total number of
product instances in the database dramatically in the general case, while having a worst-case identical to the
naive approach where each organization has its own product instance.

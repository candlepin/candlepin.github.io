---
title: Multi-Owner Users Design
---
{% include toc.md %}

# Requirements
* Allow users to be associated with more than just one owner.
* During API calls, if the user authenticating is associated with multiple
  owners but does not specify which to operate on, we assume their default
  owner.
* Expose an API call to list owners a user has access to. (users must be able
  to list owners to know which they can operate on)
* Only super admins should be able to alter the owners associated with a user.

# Tasks
1. Update data model:
   1. User.owner will remain as the users "default" owner.
   1. Add an additional many-to-many relationship, user.additionalOwners.
1. Update user service:
   1. Update the user service API to accept an optional parameter for the owner to be authenticated against.
   1. This allows the flexibility to alter the user service to 
1. Update PUT/POST /users to allow creating/updating users to reference owners. This call must be super admin only.
1. Add HTTP header specifying the owner (by key) to operate on. (Effective-Owner)
1. During authentication (creation of the Candlepin principal, happens in
   BasicAuth.java) we will need to check if the HTTP header is specified and is
   valid.
   1. If so, the owner specified will be applied to the Principal object. (which already carries an owner today)
   1. Doing so should allow our security filters to remain largely unchanged,
      as I believe these examine the principal to determine your owner, and
      subsequently what you can see.
1. If a user with access to multiple owners authenticates, but does not specify which owner to operate on, we assume their default owner.
  

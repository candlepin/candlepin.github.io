---
title: Revoke Entitlements Implementation
---
{% include toc.md %}

## Overview
Batch revocation of a set of entitlements is implemented by the method CandlepinPoolManager.revokeEntitlements. There are two major implementation goals:
 
 * performance - Batch revocation must be fast enough, because several operations such as Import Manifest may require a high number of revocations
 * locking - Entitlement is an important entity that is manipulated in various use cases. Because of that, there is a risk that the batch revoke might cause deadlocks, lock waits, and database inconsistencies. Locking must be introduced to minimize the chance of that.

General information about batch revocation of entitlements can be found [here](revoke_entitlements)
# Performance
One of the most significant performance gains is thanks to 'hibernate batch updates'. The idea is that flush() is called after batches of updates to the entities. In the past, every AbstractHibernateCurator.save() call was calling flush(), which is very slow.


# Locking
The tactic to locking is that we try to lock as many pools as possible with exclusive locks (READ_WRITE). We try to lock as soon as possible so that the batch revoke fails fast, in case locking is not possible.
The following snippet is used to mass lock Pool entities.

```java
   getEntityManager().createQuery("SELECT p FROM Pool p WHERE p in :pools") 
    .setParameter("pools", poolsToLock)
    .setLockMode(LockModeType.PESSIMISTIC_WRITE).getResultList();
```

# Run-time Consistency
This note is concerned with runtime consistency of our persistent collections. There is a certain pattern that is used in several of our methods: delete entity X, later use X or some entities in collections of X. By 'using' I mean calculating something or navigating through object tree using X. This pattern is used in our code because even after deleting an entity X, it is necessary to do some additional cleanup. Even though useful, one might run into problems when manipulating collections of X. To prevent the problems one has to be very careful about maintaining runtime-consistency (in terms of JPA specification) or they have to store the information about X somewhere else and not use deleted entities further in the code.

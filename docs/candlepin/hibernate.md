---
title: Hibernate Gotchas
---
{% include toc.md %}

# Hibernate Gotchas

## Refreshing Data when Locking  
In Candlepin we use pessimistic locking by using LockModeType.PESSIMISTIC_WRITE: 

```
Query query = this.getEntityManager()
                .createQuery("...")
                .setLockMode(LockModeType.PESSIMISTIC_WRITE);
```
Locking is important to mitigate lost update issues. Specific example is entitlement of a Pool. When request X wants to entitle a Pool, in code we must load Pool.consumed value to find out if there is any quantity left. To do so, X needs to lock the Pool and retrieve up to date value of Pool.consumed field. Without locking, another parallel request could interleave and consume the Pool, which would change Pool.consumed value, the request X would act on old value of Pool.consumed and would overconsume the Pool. 

The locking example shown above is translated by Hibernate to SELECT FOR UPDATE clause. This SQL clause achieves two things:

 1. Rows are locked. No other thread can update the rows or issue another SELECT FOR UPDATE - it must wait before the locking transaction commits
 1. Data retrieved by SELECT FOR UPDATE are sufficiently up to date (not old under repeatable read semantics)

There are several gotchas associated with Hibernate behavior that has been observed on MySQL. Suppose you want to query for Pool entity and you plan to use Pool.consumed field - you would like to make sure that the Pool.consumed is up to date and none of the parallel requests change the value. Possible problems that may arise:
 
 1. If the Pool is already loaded in the persistence context (even by an earlier transaction in the same request), you will get the cached (from persistence context) instance. Not the up to date one from SELECT FOR UPDATE result set!
 2. Any query that is not SELECT FOR UPDATE (even EntityManager.refresh() without the lock mode) may retrieve old data due to database repeatable read semantics. By 'old' I mean data that has been loaded earlier in the transaction.
 3. If some of your fields are loaded by @Formula, e.g. Pool.consumed, and you are locking parent entity (Pool), the field will be loaded without SELECT FOR UPDATE. That means old data may be loaded.

To dodge all of the above, it is important to make sure the developer understands what needs to be locked and up to date (all the particular fields that they need during their business logic). Steps to mitigate above gotchas follow naturally:

 1. Before locking either make sure the entity is not in persistence context, or refresh it directly after loading.
 2. After successfully locking an entity, the only values that can be relied upon (to be up to date) are those directly loaded by SELECT FOR UPDATE statements. To force SELECT FOR UPDATE it is necessary to query with locking mode PESSIMISTIC_WRITE. EntityManager.refresh also allows setting the LockMode.
 3. You can't really rely on any Formula queried value, because Hibernate doesn't add "FOR UPDATE" clause to inline SQL queries (it just inserts Formula into the SELECT part of the parent query).
 4. If you are absolutely sure that a value that you rely upon such as Pool.consumed has been loaded by query X and you know that X has not been issued earlier in the transaction, you can rely on that value, because repeatable read guarantee is not giving you the old value. Obviously this is an extremely haphazard implementation - it's hard to predict what Hibernate runs and when and it's impossible to make sure that nobody will reuse your data access method and runs X earlier. Also keep in mind that X doesn't have to be exact JQPL/Criteria/HQL that you run inside your code - what counts is the final SQL that RDBMS runs and caches as a repeatable read result.

## Do not add unpersisted entity to a persistent collection
Because we use @Id to implement equals() and hashCode() methods, the @Id must be populated before adding an entity into persistent collection. You can read more about this [here](https://developer.jboss.org/wiki/EqualsandHashCode)

## Maintain runtime consistency
When we delete an entity and another loaded collection (that has CascadeType CREATE) contains that entity, we should remove the entity from the loaded collection. If we don't do that, hibernate will unschedule our delete:

```
TRACE DefaultPersistEventListener[219] - un-scheduling entity deletion [[org.candlepin.model.Entitlement 
```

Note that this gotcha is sometimes hard to predict, because if the collection was not loaded in the first place, hibernate will not unschedule the entity from deletion.

## Runtime Consistency Example
This section shows several, above mentioned, gotchas by walking through part of our codebase.

Sometimes you might encounter the following error [0] 

[0]

```java
Caused by: java.sql.SQLException: Integrity constraint violation FK_ENTITLEMENT_POOL table: CP_ENTITLEMENT in statement [delete from cp_pool where id=? and version=?]  
    at org.hsqldb.jdbc.Util.throwError(Unknown Source)  
    at org.hsqldb.jdbc.jdbcPreparedStatement.executeUpdate(Unknown Source)  
    at org.hibernate.engine.jdbc.internal.ResultSetReturnImpl.executeUpdate(ResultSetReturnImpl.java:133)  
    ... 41 more 
```
{:.numbered}

[1]

```
TRACE DefaultPersistEventListener[219] - un-scheduling entity deletion [[org.candlepin.model.Entitlement  
```

Imagine a simple functional (a test that uses in memory database) test in our PoolManagerFunctionalTest:

```java
  @Test  
    public void testDeletePoolCascade() throws Exception {  
         Pool pool = createPool(o, socketLimitedProduct, 100L,  
                TestUtil.createDate(2000, 3, 2), TestUtil.createDate(2050, 3, 2));  
        poolCurator.create(pool);  
        Entitlement ent = createEntitlement(pool);  
        poolManager.deletePool(pool);  
    }  
```
{:.numbered}

The createEntitlement method just creates and persists entitlement:

```java
        private Entitlement createEntitlement(Pool p) {  
            Entitlement ent = new Entitlement();  
            ent.setOwner(o);  
            ent.setConsumer(createConsumer(o));  
            ent.setQuantity(1);  
            ent.setPool(p);  
            entitlementCurator.create(ent);  
            return ent;          
        }  
```
{:.numbered}

The test method happily passes. Now let's comment out a few lines in implementation of deletePool method:


[3]

```java
@Override
@Transactional
public void deletePool(Pool pool) {
   Event event = eventFactory.poolDeleted(pool);
   // Must do a full revoke for all entitlements:
   /*
   for (Entitlement e : poolCurator.entitlementsIn(pool)) {
     revokeEntitlement(e);
     e.getCertificates().clear();
   }
   */
   poolCurator.delete(pool);
   sink.sendEvent(event);
}
```
{:.numbered}

And you get exception [0] which indicates that you entitlements are still in the database. This is kinda surprising, because Pool.entitlements have cascade set to ALL which means it should delete them together with the pool. The reason they are not cascade deleted is because in [1] we didn't make sure we maintain runtime consistency (we didn't added the entitlement to pool's collection). So one solution to this problem is add new line 7:

[3b]

```java
    @Test  
    public void testDeletePoolCascade() throws Exception {  
        Pool pool = createPool(o, socketLimitedProduct, 100L,  
            TestUtil.createDate(2000, 3, 2), TestUtil.createDate(2050, 3, 2));  
        poolCurator.create(pool);  
        Entitlement ent = createEntitlement(pool);  
        pool.getEntitlements().add(ent);  
        poolManager.deletePool(pool);  
    }  
```
{:.numbered}



Now the entitlements will be cascade deleted. Now let's uncomment lines 6-9 of [3] and change line 6 to:

[4]

```java
    for (Entitlement e : pool.getEntitlements()) {  

```

This will work only if the runtime consistency is maintained on line 7 of [3b]. Now logical step that one might try is to use poolCurator.find instead of adding entitlement to the pools collection:

```java
    @Test  
    public void testDeletePoolCascade() throws Exception {  
        Pool pool = createPool(o, socketLimitedProduct, 100L,  
           TestUtil.createDate(2000, 3, 2), TestUtil.createDate(2050, 3, 2));  
        poolCurator.create(pool);  
        Entitlement ent = createEntitlement(pool);  
//        pool.getEntitlements().add(ent);  
        pool = poolCurator.find(pool.getId());  
        poolManager.deletePool(pool);  
    }
```
{:.numbered}


This won't work, because poolCurator.find returns the object instantiated on line 3. To make this approach work, one would have to detach the pool from entity manager on line before the line 8 (or call refresh):

```java
entityManager().detach(pool);  
```

All the code snippets above used my own createEntitlement (listed as [2]). Interesting things start to happen when instead of that method I use our standard method to create test entitlements:

```java
      Entitlement ent = createEntitlement(o, createConsumer(o),   
            pool,createEntitlementCertificate("a", "a"));  
```

So the complete test method now looks like this:

[5]

```java
    @Test  
    public void testDeletePoolCascade() throws Exception {  
        Pool pool = createPool(o, socketLimitedProduct, 100L,  
                TestUtil.createDate(2000, 3, 2), TestUtil.createDate(2050, 3, 2));  
        poolCurator.create(pool);  
        Entitlement ent = createEntitlement(o, createConsumer(o),  
                pool,createEntitlementCertificate("a", "a"));  
        ent.setQuantity(1);  
        entityManager().refresh(pool);  
        entitlementCurator.create(ent);  
        poolManager.deletePool(pool);  
    }  
```
{:.numbered}

Given the refresh on line 09, you would expect the code will pass. It wont. Instead you will get [0] again. Now the problem why this code doesn't work is much more intricate. The implementation of on createEntitlement (our standard functional test prepare method) on line 6 is:

[6]

```java
    public static Entitlement createEntitlement(Owner owner, Consumer consumer,  
        Pool pool, EntitlementCertificate cert) {  
        Entitlement toReturn = new Entitlement();  
        toReturn.setOwner(owner);  
        toReturn.setPool(pool);  
        toReturn.setOwner(owner);  
        consumer.addEntitlement(toReturn);  
        if (cert != null) {  
            cert.setEntitlement(toReturn);  
            toReturn.getCertificates().add(cert);  
        }  
        return toReturn;  
    }  
```
{:.numbered}

As you can see createEntitlement is maintaining runtime consistency (putting toReturn to consumer's entitlements) so on the first sight everything looks ok. However, an important fact to realize with this code is that we use @Id to implement equals/hashCode. As you can see on line 7 we add the pool into consumer.entitlements. This is before entitlement (toReturn) is actually persisted. So the consumer.entitlements contains the entitlement but hashed by null value of @Id. After this method finishes, the line 10 of [5] will persist entitlement. After that the entitlement gets @Id populated.

 

After that the deletePool method on line 11 of [5] will try to revoke the entitlement ent. As seen in the following code [7], the removeEntitlement method removes the entitlement on line 10 of [7] from the consumer's entitlements collection. This removal of entitlement will be unsuccessful (you can even debug that by printing boolean that remove() method returns). The reason for that is that consumers.entitlements contains the entitlement hashed by null value. But the parameter entitlement on line 10 of [7] has hashCode and equals method that  is already based on the populated @Id. Because the removal on line 10 fails and because we have CascadeType CREATE on Consumer.entitlements, the Hibernate unschedules delete of the entitlement. This causes the foreign key exception.

[7]

```java
    @Transactional  
        void removeEntitlement(Entitlement entitlement, boolean regenModified) {  
            Consumer consumer = entitlement.getConsumer();  
            Pool pool = entitlement.getPool();  
      
            // Similarly to when we add an entitlement, lock the pool when we remove one, too.  
            // This won't do anything for over/under consumption, but it will prevent  
            // concurrency issues if someone else is operating on the pool.  
            pool = poolCurator.lockAndLoad(pool);  
            consumer.removeEntitlement(entitlement);  
```
{:.numbered}

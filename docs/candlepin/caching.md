---
title: Caching - JCache and Candlepin Second Level Cache
---
## Caching
We use two kinds of caches
  
 * JCache (JSR-107) - this caching standard is useful for caching key-value data
 * Hibernate Second Level Cache (2LC) - method for caching entities, collection of entities and even results of JPQL/Criteria/HQL queries

Both cache types are provided by implementation EHCache, version 2.10.2, see [JavaDoc](http://www.ehcache.org/apidocs/2.10.2/index.html) and [reference documentation](http://www.ehcache.org/generated/2.10.2/html/ehc-all/). For EHCache, We maintain 2 configuration files: ehcache.xml and ehcache-stats.xml. Both should be kept in sync, the only difference is that '-stats' one have statistics enabled, so that its possible to turn on statistics at deploy time via Candlepin configuration.

Current version of Hibernate that we use is 5.1.1 (see [documentation](http://hibernate.org/orm/documentation/5.1/)). Hibernate docs contain specific chapters on 2LC [Chapter 13, Caching](http://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/Hibernate_User_Guide.html#caching). For more in-depth introduction, I recommend the following links:

 * [How does Hibernate store second-level cache entries](https://vladmihalcea.com/2015/04/09/how-does-hibernate-store-second-level-cache-entries/) 
 * [How Hibernate Query Cache Works](https://vladmihalcea.com/2015/06/08/how-does-hibernate-query-cache-work/)
 * [How Hibernate Collection Cache Works](https://vladmihalcea.com/2015/05/11/how-does-hibernate-collection-cache-work/)
 * [NONSTRICT\_READ\_WRITE](https://vladmihalcea.com/2015/05/18/how-does-hibernate-nonstrict_read_write-cacheconcurrencystrategy-work/)

### Configuration and Statistics
To enable JMX statistics, use the following settings in candlepin.conf

```
cache.jmx.statistics=true
jpa.config.net.sf.ehcache.configurationResourceName=ehcache-stats.xml
```

You also need to enable JMX in your /etc/tomcat/tomcat.conf:

```
JMX_CONF="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=3322   -Dcom.sun.management.jmxremote.ssl=false   -Dcom.sun.management.jmxremote.authenticate=false "

JAVA_OPTS=" $JMX_CONF ..."
```

Then you can connect to JMX server, using JConsole:  jconsole localhost:3322 

### Using JCache
Classes that support caching are located in package `org.candlepin.cache`

If you are not going to use any existing cache, you need to configure a new one in `CacheContextListener`

To use already configured cache, inject `CandlepinCache`. Example usage:

```java
  Cache<String, Status> statusCache = candlepinCache.getStatusCache();
  Status cached = statusCache.get(CandlepinCache.STATUS_KEY);
  ...
  statusCache.put(CandlepinCache.STATUS_KEY, status);
```
{:.numbered}

Note that `Cache` interface is from JSR-107. We are trying to use interfaces from JSR-107 as much as possible, so that we can potentially swap caching implementations in the future.

### Using 2LC - Hibernate 2nd Level Cache
To cache entities using 2LC, it is necessary to use appropriate annotations: 

```java
@Cacheable(true)
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
public class Content extends AbstractHibernateObject implements SharedEntity, Cloneable {
```

You can also cache collections on entities:

```java
@Cache(usage = CacheConcurrencyStrategy.NONSTRICT_READ_WRITE)
private Set<String> modifiedProductIds;
```

Another feature of 2LC is query caching. To use it, you need to indicate that a query should be cached using `setCacheable` method:

```java
@Transactional
public Content lookupByUuid(String uuid) {
   return (Content) currentSession().createCriteria(Content.class).setCacheable(true)
       .add(Restrictions.eq("uuid", uuid)).uniqueResult();
}
```

To find out if the cache is effective you should either use profiler to see number of SQL queries generated, or you can use JConsole and see cache statistics (cache hits).

There is one warning associated with using 2LC. We are currently not deploying EHCache in clustered mode. That means that in a cluster, cached entities might become stale (invalidation across nodes doesn't work). We plan to get around this issue by making sure any entity that we cache is immutable across cluster nodes. For example `Product` entity is being mutated but only on 1 Candlepin node during import manifest. That is fine, because cache will get invalidated locally.

### How to Use 2LC Effectively
To make use of Hibernate Second Level Cache, it is important to understand how it works and when Hibernate uses it to retrieve cached entities. This page will try to explain this by using examples in Candlepin sources. 

In Candlepin, we mainly cache `Product`/`Content` entities and all the collections (e.g. attributes, productContent) that are on them. The reason this is a good choice is that these entities are almost completely immutable which means we don't have to worry about invalidation.

Very simplified view of when Hibernate uses 2LC can be summarized as follows:

 * When entity is looked up by its `Id` column
 * When entity is defiend as ManyToOne attribute and isn't referenced in the query (when the attribute is referenced in the query, Hibernate will usually issue a Sql Join to load the attribute value)
 * When persistent collection is cached (`Cache` annotation on the collection), the entities in that collection will be loaded from 2LC
 * A query is cached and the results are cached entities - this is quite obvious
 * When using old Hibernate Criteria - this is a bit odd, but when using old Hibernate Criteria, Hibernate is sometimes less proactive doing Sql Joins and instead it is loading associated relationship using separate selects. Which means you may get more cache hits

On the flip side, you won't get cache hits when you have a complex query in which you JOIN cached entity (Product/Content). This happens quite often in Candlepin. The solution is to rewrite the specific piece of code to use more LAZY loading of `Product` or `Content`. 


### Example with OwnerProduct 
To realize M to N relationship between `Owner` and `Product` we have a special third entity `OwnerProduct`. It has the following relationship defined

```java
    @ManyToOne(fetch=FetchType.LAZY, optional=false)
    @JoinColumn(updatable = false, insertable = false)
    private Product product;
```
{:.numbered}

Imagine one wants to find a `Product` for an `Owner`. He might use the following query A:

```java
    public Product getProductByIdJpqlNoCacheHit(String ownerId, String productId) {
        TypedQuery<Product>  query = 
                getEntityManager().createQuery("SELECT op.product FROM OwnerProduct op WHERE op.product.id=:productId and op.owner.id = :ownerId",Product.class)
                .setParameter("ownerId", ownerId)
                .setParameter("productId", productId);
        
        return query.getSingleResult();
    }
```
{:.numbered}

This query will populate `Product` 2LC. However, upon repeated calls, it will NOT hit `Product` from the cache. Instead, Hibernate will issue a SQL query:

```
    select
        product1_.uuid as uuid1_13_,
        product1_.created as created2_13_,
        product1_.updated as updated3_13_,
        product1_.entity_version as entity_v4_13_,
        product1_.product_id as product_5_13_,
        product1_.locked as locked6_13_,
        product1_.multiplier as multipli7_13_,
        product1_.name as name8_13_ 
    from
        cp2_owner_products ownerprodu0_ 
    inner join
        cp2_products product1_ 
            on ownerprodu0_.product_uuid=product1_.uuid 
    where
        product1_.product_id=? 
        and ownerprodu0_.owner_id=?
```

Even though `Product` is not taken from cache here, we are still getting benefit from 2LC, because `Product.attributes` and `Product.productContent` are cached and retrieved from cache. One would still like to utilize cache even for retrieval of `Product` entity. There are several ways to do that:
  
 * Query for `OwnerProduct` entity and set `OwnerProduct.product` relationship as LAZY - shown below
 * Query for `OwnerProduct` entity and set `OwnerProduct.product` as EAGER with Fetch style SELECT
 * Query for `OwnerProduct` entity and then manually query for `Product` using its UUID

Lets discuss the first option. Becuase we set `OwnerProduct.product` to LAZY, Hibernate is not going to join when we execute the query. Then, because `OwnerProduct.product` is a relationship that retrieves just one Product, Hibernate will utilize 2LC. The code might look like this:

```
    public Product getProductByIdJpql(String ownerId, String productId) {
        TypedQuery<OwnerProduct>  query = 
                getEntityManager().createQuery("SELECT op FROM OwnerProduct op WHERE op.product.id=:productId and op.owner.id = :ownerId", OwnerProduct.class)
                .setParameter("ownerId", ownerId)
                .setParameter("productId", productId);
        
        return query.getSingleResult().getProduct();
    }
```
{:.numbered}

If the `Product` is not yet in the cache, the run of the `getProductByIdJpql` will produce the following two SQL statements:

```
    select
        ownerprodu0_.owner_id as owner_id1_5_,
        ownerprodu0_.product_uuid as product_2_5_ 
    from
        cp2_owner_products ownerprodu0_ cross 
    join
        cp2_products product1_ 
    where
        ownerprodu0_.product_uuid=product1_.uuid 
        and product1_.product_id=? 
        and ownerprodu0_.owner_id=?

    select
        product0_.uuid as uuid1_13_0_,
        product0_.created as created2_13_0_,
        product0_.updated as updated3_13_0_,
        product0_.entity_version as entity_v4_13_0_,
        product0_.product_id as product_5_13_0_,
        product0_.locked as locked6_13_0_,
        product0_.multiplier as multipli7_13_0_,
        product0_.name as name8_13_0_ 
    from
        cp2_products product0_ 
    where
        product0_.uuid=?
```

With repeated invocations, the second statement will not be issued.

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

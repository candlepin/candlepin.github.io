---
layout: default
categories: developers
title: Paginating Results
---
{% include toc.md %}

### Warning
{:.alert-bad .no_toc}

Pagination is not bulletproof.  If the results you are paging from are changed,
you can miss items or receive duplicate items.  **If you absolutely must have
every item, don't use paging**.

The problem is we are dealing with is when the data changes while you are
paging through it.  For example, the requester asks for the first 10 records.
You return records 1 through 10.  Then someone deletes record 2.  The requester
then asks for the second 10 records.  The first 10 records are now records 1
and 3 through 11 (since record 2 has been deleted).  The second 10 would then
be records 12 through 22.  Effectively, the person paging through the data has
missed record 11 without knowing it.

# Paginating Results From Candlepin
Certain calls made to Candlepin can be given parameters that will cause
Candlepin to return the results back in pages.  Currently those calls are

* /owners/*id*/consumers
* /consumers
* /owners/*id*/pools
* /pools
* /consumers/*id*/entitlements
* /entitlements

You can specify four parameters that affect paging.

page
: The page to request.  Must be greater than zero.

per_page
: The number of results to include per page.  Defaults to 10.

order
: The order to sort the results in.  Can be "asc", "desc", "ascending", or
"descending" (case insensitive).  Defaults to descending.

sort_by
: The field to sort the data by.  Defaults to the created date.

The _order_ and _sort_by_ options can alternately be specified without the
_page_ and _per_page_ parameters.  In this case, all the results will be
returned sorted in the manner specified by the parameter values.

## The Link Header
When the _page_ and _per_page_ parameters are specified, a special header named
*Link* is returned with the response.  The URLs within the Link header provide
navigation to the first, next, previous, and last pages.  Please see [RFC
5988](http://tools.ietf.org/html/rfc5988) for a full specification of the Link
header.  The header provides a list of links separated by commas.  Each link is
split into a URL (surrounded by angle brackets) and it's relation defined by
the string `rel="RELATION_NAME"`.  The four relation names are `first`, `next`,
`prev`, and `last`.  A simple parser for the Link header can be found
[here](https://github.com/eclipse/egit-github/blob/master/org.eclipse.egit.github.core/src/org/eclipse/egit/github/core/client/PageLinks.java).
You should use the Link header to navigate rather than trying to craft URLs
yourself.

## How Paging Works
In order to add paging to a resource, the first thing you must do is tag the
resource method with the
[@Paginate](https://github.com/candlepin/candlepin/blob/76e2404d2c08ff87085503f658203a6a7e75e715/src/main/java/org/candlepin/paging/Paginate.java)
annotation.  It is this annotation that invokes the
[PageRequestInterceptor](https://github.com/candlepin/candlepin/blob/master/src/main/java/org/candlepin/resteasy/interceptor/PageRequestInterceptor.java?source=cc).
The interceptor is a RESTEasy interceptor that examines the query string for
the parameters specified above.  It takes the values of these parameters and
sets them in an object called a
[PageRequest](https://github.com/candlepin/candlepin/blob/76e2404d2c08ff87085503f658203a6a7e75e715/src/main/java/org/candlepin/paging/PageRequest.java).
After dealing with the various cases of when to use defaults, the
PageRequest is then placed in the context.

The next thing to do is modify the resource method to take and read the
PageRequest object.  This is as simple as adding `@Context PageRequest
pageRequest` to the parameter list in the method signature.  Now you need to do
your paging magic (more on this later) and create a
[Page](https://github.com/candlepin/candlepin/blob/76e2404d2c08ff87085503f658203a6a7e75e715/src/main/java/org/candlepin/paging/Page.java) object.  The page object has three fields that must be set: the actual page
data (a Java Collection), the maximum number of records, and the PageRequest
that was sent into the method.  You then place the Page object into the context
with a 

```java
ResteasyProviderFactory.pushContext(Page.class, page);
```

and return the page data of the page.  The Page object must be placed in the
context so that the
[LinkHeaderPostInterceptor](https://github.com/candlepin/candlepin/blob/76e2404d2c08ff87085503f658203a6a7e75e715/src/main/java/org/candlepin/resteasy/interceptor/LinkHeaderPostInterceptor.java)
can have access to the paging information to build the navigation links.

Here's a simple example of Resource method that has pagination enabled.

```java
@GET
@Produces(MediaType.APPLICATION_JSON)
@Wrapped(element = "consumers")
@Paginate
public List<Consumer> list(@QueryParam("username") String userName,
    @QueryParam("type") String typeLabel,
    @QueryParam("owner") String ownerKey,
    @Context PageRequest pageRequest) {
    ConsumerType type = null;

    if (typeLabel != null) {
        type = lookupConsumerType(typeLabel);
    }

    Owner owner = null;
    if (ownerKey != null) {
        owner = ownerCurator.lookupByKey(ownerKey);

        if (owner == null) {
            throw new NotFoundException(
                i18n.tr("Organization with key: {0} was not found.",
                    ownerKey));
        }
    }

    // We don't look up the user and warn if it doesn't exist here to not
    // give away usernames
    Page<List<Consumer>> p = consumerCurator.listByUsernameAndType(userName,
        type, owner, pageRequest);

    // Store the page for the LinkHeaderPostInterceptor
    ResteasyProviderFactory.pushContext(Page.class, p);
    return p.getPageData();
}
```

Earlier I mentioned that some _paging magic_ must occur.  This magic occurs in
the Hibernate layer.  There are two methods, `listAll()` and `listByCriteria()`
in the
[AbstractHibernateCurator](https://github.com/candlepin/candlepin/blob/master/src/main/java/org/candlepin/model/AbstractHibernateCurator.java?source=cc)
that have signatures that accept PageRequest objects.  These methods are
written to examine the PageRequest object and create a resultant Page object.
Ideally, the best way is to have a method in your curator that builds a
DetachedCriteria object with your necessary filters.  Then send that
DetachedCriteria and the PageRequest into `listByCriteria()`.  You will receive
a Page object back.

What if you need to perform some filtering of the data after you read it back
from the database?  So far, my solution has been to read all the data, filter
it, take a sublist of the correct size, and throw the rest of the data away.
This may sound wasteful, but it is still faster than returning all the results
in JSON as the serialization of the objects to JSON takes a significant amount
of time.

There are a few things to keep in mind if you must perform post-read filtering
and wish to use the magic methods in AbstractHibernateCurator

* You should use the `listAll()` or `listByCriteria()` method that takes a
  boolean parameter called `postFilter`.  Since you will be doing
  post-filtering, pass in true.  With a true value, the method will send in the
  PageRequest's _sortBy_ and _order_ values to the normal `listAll()` or
  `listByCriteria()`.  They do this by creating a dummy PageRequest with these
  values set and the paging values left `null`.  It also sets the PageRequest
  back to the true pageRequest after making the call to `listAll()` or
  `listByCriteria()` since otherwise the magic method will set it to the dummy.
* You must be *careful* when taking the sublist.  Use the following method in
  AbstractHibernateCurator.

  ```java
  public List<E> takeSubList(PageRequest pageRequest, List<E> results) {
      int fromIndex = (pageRequest.getPage() - 1) * pageRequest.getPerPage();
      if (fromIndex >= results.size()) {
          return new ArrayList<E>();
      }

      int toIndex = fromIndex + pageRequest.getPerPage();
      if (toIndex > results.size()) {
          toIndex = results.size();
      }
      // sublist returns a portion of the list between the specified fromIndex,
      // inclusive, and toIndex, exclusive.
      return results.subList(fromIndex, toIndex);
  }
  ```
* Don't forget to set the Page's `maxRecords` to the number of records in the sublist and don't forget to set the `pageData` to the sublist you create!

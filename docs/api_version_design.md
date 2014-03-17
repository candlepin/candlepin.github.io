---
layout: default
title: API Version Design
---
{% include toc.md %}

# API Version Design
Today Candlepin has only one API which causes a problem with revising and
backwards compatibility. There are a few ways we can solve this and they each
have their pros and cons. They all have a common solution which is versioning
the API, the difference is in implementation.

## URL versioning
This is a classic form of versioning APIs used by many sites.
[Smugmug](https://wiki.smugmug.net/display/API/API+1.2.2),
[Google](https://developers.google.com/maps/documentation/javascript/basics#Versioning),
and many others.

The change involves adding the version to the URL in either straight up number
or v#. For example, `/candlepin/VERSION/owners/` i.e. `/candlepin/v1.1/owners/`
or `/candlepin/1.1/owners/`. 

I think if we go with this approach it's best to create a new Java package with
the versions in it or some other way of breaking up the resources
i.e. candlepin.resource.1.1.OwnerResource. One possible solution to avoid
duplication of code is to inherit from older resources. 1.1.OwnerResource
would extend resource.OwnerResource. The big downside to this approach is the
deep tree we will end up with. If we want to avoid the tree, we can use
composition and call the unchanged methods from the other resources. 

### Pros
* seems pretty simple
* obvious to the caller that there is a change

### Cons
* ugly urls
* duplication of code possible
* maintainability will be difficult

## Custom mime types

Another idea floating around is creating media types to handle the versions.
Peter Williams used this idea to version his APIs: <http://barelyenough.org/blog/2008/05/versioning-rest-web-services>.

Bill Burke outlines using media types to distinguish API versions in his
[RESTful Java with
JAX-RS](http://www.amazon.com/RESTful-Java-Jax-RS-Animal-Guide/dp/0596158041/ref=sr_1_2?ie=UTF8&qid=1336595002&sr=8-2)
book. Effectively, you define a new media type under the vendor tree `vnd` for
example: `application/vnd.rht.customers+json` or
`application/vnd.candlepin.owners+json;version=1.1`.
Then you add `@Produces` to the methods that are upgraded.

Benefits to using the media type are we can continue to use the same resources classes and urls.

Legacy clients would be unchanged, Candlepin would continue to accept plain
JSON. New clients would send up
`application/vnd.candlepin.owners+json;version=1.1` as the accept header.

### Findings
* Sending newer version to older api version.

  ```
  curl -k -u admin:admin -H "Accept: application/vnd.candlepin.status+json;version=2.0" https://localhost:8443/candlepin/status/newstatus/
  {"displayMessage":"Runtime Error No match for accept header at org.jboss.resteasy.core.registry.Segment.match:119"}
  ```

* Sending no header defaults to JSON (that's candlepin doing that):

  ```
  curl -k -u admin:admin https://localhost:8443/candlepin/status/newstatus/
  {"result":true,"version":"0.6.2","release":"1","standalone":true,"timeUTC":"2012-05-15T16:58:40.862+0000"}
  ```

* Sending non matching header (older client to a new method):

  ```
  curl -k -u admin:admin -H "Accept: application/vnd.candlepin.status+json" https://localhost:8443/candlepin/status/newstatus/
  {"displayMessage":"Runtime Error No match for accept header at org.jboss.resteasy.core.registry.Segment.match:119"}
  ```

* Calling updated version of status:

  ```
  curl -k -u admin:admin -H "Accept: application/vnd.candlepin.status+json;version=1.1" https://localhost:8443/candlepin/status/
  {"result":true,"version":"0.6.2","release":"1","standalone":true,"timeUTC":"2012-05-15T17:01:16.536+0000"}
  ```

* Using 2 methods with same url but different `@Produces` to differentiate versions:

  ```
  curl -k -u admin:admin -H "Accept: application/vnd.candlepin.status+json;version=1.1" https://localhost:8443/candlepin/status/
  {"result":true,"version":"0.6.2","release":"1","standalone":true,"timeUTC":"2012-05-15T17:13:28.328+0000"}
  ```
  
  ```
  curl -k -u admin:admin -H "Accept: application/vnd.candlepin.status+json;version=1.5" https://localhost:8443/candlepin/status/
  {"result":true,"version":"status1.5","release":"5","standalone":true,"timeUTC":"2012-05-15T17:13:52.613+0000"}
  ```

### Pros
* URLs stay the same
* Allows adding versions to existing resources and still remaining backwards compatible
* Code reuse since we're still in the existing resources

### Cons
* not obvious to the caller you're using a different version
* unknown solution, will need to prototype something

## Use Candlepin Version
Today we do a lot of work to maintain backwards compatibility with older
clients. Maybe it is possible to simply use the `/status` url to determine a
particular Candlepin version that supports the feature needed by the client.

### Pros
* Not a lot of duplication of code
* clients continue to work no url or header changes
* simple client change to ask for version

### Cons
* keeping track of what Candlepin version has what API features

### Issues
* need a deprecation strategy for the API
* make sure old clients continue to work
* what testing efforts will we need? clearly spec tests to make sure we don't screw up the old version. unit tests?
* how do we account for database changes?
* could store the version in a header X-Candlepin-API-Version:

## Questions
Please add your questions and comments to the bottom with your username.

 * dgoodwin: How does the client know what version to talk to? (we have been investing a lot in having the client talk to older Candlepin's) Does this imply python-rhsm needs to know how to talk to multiple versions of Candlepin? Are we any better off if it does?
   * jbowes: I'd expect that each release of the client would know how to talk to only a single version of candlepin, or maybe 2, like in the cases we've had recently with SLA. I wouldn't expect 
     it to be able to talk to _all_ versions. Candlepin, on the other hand, would need to speak to all versions of python-rhsm.
   * zeus: +1 new versions know how to talk to their version of candlepin. But the server needs to speak all versions (up to a point).
 * dgoodwin: What constitutes a new *version* of the API? Any behavioral change? Any release? Any major release?
   * jbowes: if we can support minor api rev bumps that are backwards compatible (ie adding a new field onto a json struture makes the api 1.1, but 1.0 clients can still speak to it), then I'd 
     bump for any new feature. for major api revs, we'd bump whenever we have to make a change that old clients couldn't understand, for example a new certificate format.
 * dgoodwin: How do we maintain test coverage across all versions?
   * zeus: from a spec test perspective, this will involve adding NEW tests when we bump versions for an api method
 * wottop: The database issue should be in all caps and bold. It is the biggest issue we have.
   * zeus: changing an existing fields type will be a HUGE problem
   * zeus: changing field length will be ok if we're increasing it. If making it smaller is ok as long as we don't go below the smallest value a client sends.
   * zeus: adding new model should be ok
   * zeus: adding required fields to existing objects can be problematic and will require defaulting or need to update *ALL* clients
 * jbowes: For each example, I'd like to see how we might handle:
   * legacy clients, how do we support existing clients that don't expect there to be an api version
   * removing individual methods or entire resources from a new api version
   * minor version bumps. can we add to the API in a backwards compatible way, and easily have both old and new clients speak to it?
   * a new major api version of the same api endpoint. can the mediatype style handle multiple functions all using the same url?
 * jbowes: for the first example, could we just subclass an old version of an api resource? if that works, how would we deprecate or remove methods?

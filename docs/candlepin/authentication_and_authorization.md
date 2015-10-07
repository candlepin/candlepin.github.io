---
title: Authentication and Authorization
---
{% include toc.md %}

# Authentication Mechanisms
Candlepin supports four modes of authentication. Two of the modes require that
a request provide explicit authentication.  The other two defer authentication
to external systems. They are presented below in the order in which they are
checked. By default, all authentication modes are enabled. If one mode
authenticates a user or a consumer successfully, then no other types are
checked.

Once authenticated a Principal is created with a collection of Roles which are discussed below.

## OAuth
OAuth is used to provided a secure connection with an external system which
does the authentication. You can learn more about configuring OAuth
[here](oauth.html)

## Trusted Authentication
Trusted auth behaves much like OAuth, but with no additional headers used to
protect against replay attacks. It is the most simple form of integration, but
requires firewalls and other OS level hardening to protect the engine against
attacks. With this form of authentication, the engine looks for either a
`cp-consumer` header or a `cp-user` header. If either is present, then the
engine will treat them as authenticated.  This authentication mode can be
enabled with:

```properties
candlepin.auth.trusted.enabled = true
```

If desired the `cp-lookup-permissions` header can be set to "true", which will
trigger a call back to the configured user service asking for the users actual
permissions, which will then be enforced in Candlepin.

## Basic Http
HTTP Basic Auth is used to pass user credentials. This authentication mode can
be enabled with:

```properties
candlepin.auth.basic.enabled = true
```

## X509 Certificates
Identify certificates, which are created by Candlepin, can be used to
authenticate consumers.  This authentication mode can be enabled with:

```properties
candlepin.auth.ssl.enabled = true
```

and in Tomcat's `server.xml`:

```xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
           maxThreads="150" scheme="https" secure="true"
           clientAuth="want" sslProtocol="TLS"
           keystoreFile="conf/keystore"
           truststoreFile="conf/keystore"
           keystorePass="password"
           truststorePass="password" />
```

`keystore` is a Java keystore created by `keytool`; it should contain the CA
certificate used to sign client certificates so the server can verify them.

# Authentication Specifics

## Principals
Principals are created by whichever authentication mechanism is used and carry a
list of permissions.

The two main types of principals in use today:

**UserPrincipal**
: Represents an authenticated user account and carries Permissions.  The
  permissions are discovered by asking the configured UserServiceAdapter to
  return the user object in question and to assemble the total list of
  permissions on that user.

**ConsumerPrincipal**
: An authenticated consumer. Usually this is a system registered to the
  server and authenticated by using its identity certificate.  This Principal
  carries permissions that are essentially hard coded since we assign special
  Permission sub-classes which allow a Consumer to do the things it needs to do
  and nothing more.

## Permissions
Objects carried by principals which grant access to domain model objects of a
particular type. These sometimes match based on an access level. There are
several types of permissions, created as needed to solve specific situations we
encounter.  Some permission types in use today:

**OwnerPermission**
: One of the most important; this is the permission which grants user accounts
  access to manage owners at some access level. This permission is the only
  type which can be associated to a Role, and is stored in the database.

**UsernameConsumersPermission**
: Used to grant a user access to register systems and manage only those that
  they registered. Must be combined with other more fine grained permissions
  for some operations.

**ConsumerPermission**
: Used to grant a consumer permission to manage themselves.  Doesn't really
  use Access levels.

**ConsumerEntitlementPermission**
: Used to grant a consumer permission to manage their entitlements, but not
  those of any other consumer, in their owner or otherwise. Doesn't really
  use Access levels.

Permissions also have the ability to inject filters into some database queries
allowing certain records to be created. This is primarily useful for "my
system" administrators who need to be able to list the consumers in an org, but
may only be able to see those that match their username.

## Roles
Roles are a database construct allowing us to store information about what
permissions the role grants and which users they are associated with. Because
most deployments of Candlepin do now actually use our user service, roles are
largely out of the picture.

Roles are defined by a name, a set of permission blueprints the role grants,
and a set of users who have this role. Permission blueprints are just enough
information for the engine to know which concrete Permission class to create
and what parameters to pass it.

Note that a principal does not carry roles, only permissions. In the case of a
UserPrincipal, the permissions carried would be the entire set of all
permissions from all their roles. In this regard Roles are somewhat just an
implementation detail of the currently configured UserServiceAdapter.

Roles can be created and managed by super admins over the REST API. (See /roles
resource) This assumes that the UserServiceAdapter supports them, otherwise an
exception will be thrown indicating the operation is not supported.

Currently Candlepin supports the following roles:

**Consumer**
: A role for consumers (generally systems), provides access to bind,
  etc. This role is generally only given out to a principal created via
  authentication with an X509 identity certificate.

**Super Admin**
: A role for Candlepin administration, also likely only given out
  via basic authentication for users who are a part of the default system
  owner. This role allows access to all URIs in Candlepin.

**Owner Admin**
: A role for administrators within an owner. This role is likely
  only given out when basic authentication is used. This role allows access to
  consumer registration, and various other URIs related to managing your
  owner's subscriptions. Can be created read-only, in which case the admin can
  only view the owner, not register or make any changes.

**"My Systems" Admin**
: A role for administrators who can register systems, but
  then only manage the systems they registered. Can be combined with a
  read-only owner admin permission.

# Authorization

## Overview
Whenever a request comes in, the authentication code kicks in resulting in a
configured Principal class.  Subsequently, an implementation of the
AbstractAuthorizationFilter is triggered to examine the method being invoked and
determine if the Principal should be able to call that method.

There are three implementations of the AbstractAuthorizationFilter.  During
servlet initialization, the AuthorizationFeature is invoked for each resource
method and it determines which filter is appropriate for that method.  That
determination is only done at initialization time and does not impose additional
overhead during a request.

If the method has an `@SecurityHole` annotation, the
SecurityHoleAuthorizationFilter is used.  If the method has any parameters with
an `@Verify` annotation, the VerifyAuthorizationFilter is used.  Otherwise, the
SuperAdminAuthorizationFilter is used.

WARNING: The AuthorizationFeature class implements the JAX RS 2.0 DynamicFeature
interface.  Do not use the `@Provider` annotation on filters meant to be applied
to methods using a `DynamicFeature` implementation as Resteasy will get confused
about which resource methods to actually apply the filter to.
{:.alert-bad}

## SecurityHoleAuthorizationFilter
The SecurityHoleAuthorizationFilter is a no-op filter and all methods assigned
to this filter will always authorize successfully.

## SuperAdminAuthorizationFilter
The SuperAdminAuthorizationFilter is a very strict filter that only authorizes
Principals who have the superadmin role.

## VerifyAuthorizationFilter
The VerifyAuthorizationFilter provides object level granularity for
authorization.  Any object with an `@Verify` annotation will be examined to make
sure that the requesting Principal has access to that object with the required
access level.

An example:

```java
    @PUT
    @Produces(MediaType.APPLICATION_JSON)
    @Path("{consumer_uuid}")
    @Transactional
    public void updateConsumer(
        @PathParam("consumer_uuid") @Verify(Consumer.class) String uuid,
        Consumer consumer, @Context Principal principal) {
```

In the example above the @Verify annotation tells the VerifyAuthorizationFilter we
need to lookup a consumer with the given UUID, and ask the current principal if
we have access to it.

Objects annotated with `@Verify` can specify a required access level, but if
none is specified, the VerifyAuthorizationFilter uses a default access level
based on the HTTP verb of the request.

The default access level requirements are

* Access.ALL for PUT and DELETE requests
* Access.CREATE for POST requests
* Access.READ_ONLY for all other requests

The Verify annotation can also carry a sub-resource, which allows for
situations where for example, a consumer needs to be able to list an org's
pools (GET /owners/{key}/pools}, but we do not want to grant it read-only
access to the entire org. The sub-resource is passed through to the Permissions
when asking if the principal has access, and each permission can be as specific
or general as it likes with respect to this information.


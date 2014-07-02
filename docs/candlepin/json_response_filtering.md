---
categories: usage
title: JSON Response Filtering
---
{% include toc.md %}

# JSON Response Filtering
Candlepin has the ability to filter json responses of most objects to reduce the size of the payload and provide exactly the information that is requested.

## Using JSON Filtering
Using JSON filtering is very easy, you simply append a keyword to the url with the object property you want it to modify.

### Keywords
 1. include
 2. exclude

### Modified Property Values
The value is simply the name of the json field. for instance, if my response is the json object:

```json
{
    id: "someid",
    value: {id: "otherid", data: "this is data"}
}
```

by specifying to &include=id we would receive:

```json
{
    id: "someid"
}
```

or &include=value.data:

```json
{
    value: {data: "this is data"}
}
```

or &exclude=value.data:

```json
{
    id: "someid",
    value: {id: "otherid"}
}
```

## Other notes
 * It is not possible to use both include and exclude in the same query
   * However you may use multiple of either filer type.
 * When the response is a list, a filter is applied to each member of the list
   * This is also applied on nested properties.  A consumer has a list of guestIds, so I can "exclude=guestIds.updated" in order to hide updated dates on all guestIds

## Examples

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/consumers/c50e8819-af96-48a1-8168-ec8e2e5487a9"
```

```json
{
  "id" : "ff80808146f2e3f60146f301d7550078",
  "uuid" : "c50e8819-af96-48a1-8168-ec8e2e5487a9",
  "name" : "haa",
  "username" : null,
  "entitlementStatus" : "valid",
  "serviceLevel" : "",
  "releaseVer" : {
    "releaseVer" : null
  },
  "idCert" : {
    "key" : "-----BEGIN...",
    "cert" : "-----BEGIN CE...",
    "id" : "ff80808146f2e3f60146f301d976007b",
    "serial" : {
      "id" : 6391652322699459734,
      "revoked" : false,
      "collected" : false,
      "expiration" : "2030-07-01T17:38:42.650+0000",
      "serial" : 6391652322699459734,
      "created" : "2014-07-01T17:38:42.650+0000",
      "updated" : "2014-07-01T17:38:42.650+0000"
    },
    "created" : "2014-07-01T17:38:43.190+0000",
    "updated" : "2014-07-01T17:38:43.190+0000"
  },
  "type" : {
    "id" : "1004",
    "label" : "hypervisor",
    "manifest" : false
  },
  "owner" : {
    "id" : "ff80808146f2a6c70146f2a6d83c0003",
    "key" : "admin",
    "displayName" : "Admin Owner",
    "href" : "/owners/admin"
  },
  "environment" : null,
  "entitlementCount" : 0,
  "facts" : {
    "uname.machine" : "x86_64"
  },
  "lastCheckin" : null,
  "installedProducts" : [ ],
  "canActivate" : false,
  "guestIds" : [ {
    "id" : "ff80808146f2e3f60146f303d1790082",
    "guestId" : "g4",
    "created" : "2014-07-01T17:40:52.217+0000",
    "updated" : "2014-07-01T17:40:52.217+0000"
  } ],
  "capabilities" : [ ],
  "hypervisorId" : {
    "id" : "ff80808146f2e3f60146f301d7560079",
    "hypervisorId" : "haa",
    "created" : "2014-07-01T17:38:42.646+0000",
    "updated" : "2014-07-01T17:38:42.646+0000"
  },
  "autoheal" : true,
  "href" : "/consumers/c50e8819-af96-48a1-8168-ec8e2e5487a9",
  "created" : "2014-07-01T17:38:42.645+0000",
  "updated" : "2014-07-01T17:38:43.262+0000"
}
```

Can become much more readable by removing the id certificate and key, facts, guestIds, and hypervisorId

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/consumers/c50e8819-af96-48a1-8168-ec8e2e5487a9?exclude=idCert.cert&exclude=idCert.key&exclude=facts&exclude=guestIds&exclude=hypervisorId"
```

```json
{
  "id" : "ff80808146f2e3f60146f301d7550078",
  "uuid" : "c50e8819-af96-48a1-8168-ec8e2e5487a9",
  "name" : "haa",
  "username" : null,
  "entitlementStatus" : "valid",
  "serviceLevel" : "",
  "releaseVer" : {
    "releaseVer" : null
  },
  "idCert" : {
    "id" : "ff80808146f2e3f60146f301d976007b",
    "serial" : {
      "id" : 6391652322699459734,
      "revoked" : false,
      "collected" : false,
      "expiration" : "2030-07-01T17:38:42.650+0000",
      "serial" : 6391652322699459734,
      "created" : "2014-07-01T17:38:42.650+0000",
      "updated" : "2014-07-01T17:38:42.650+0000"
    },
    "created" : "2014-07-01T17:38:43.190+0000",
    "updated" : "2014-07-01T17:38:43.190+0000"
  },
  "type" : {
    "id" : "1004",
    "label" : "hypervisor",
    "manifest" : false
  },
  "owner" : {
    "id" : "ff80808146f2a6c70146f2a6d83c0003",
    "key" : "admin",
    "displayName" : "Admin Owner",
    "href" : "/owners/admin"
  },
  "environment" : null,
  "entitlementCount" : 0,
  "lastCheckin" : null,
  "installedProducts" : [ ],
  "canActivate" : false,
  "capabilities" : [ ],
  "autoheal" : true,
  "href" : "/consumers/c50e8819-af96-48a1-8168-ec8e2e5487a9",
  "created" : "2014-07-01T17:38:42.645+0000",
  "updated" : "2014-07-01T17:38:43.262+0000"
}
```

Or if I just want a mapping of consumer uuid to guestIds

```console
$ curl -k -u admin:admin "https://localhost:8443/candlepin/consumers/c50e8819-af96-48a1-8168-ec8e2e5487a9?include=uuid&include=guestIds.guestId"
```

```json
{
  "uuid" : "c50e8819-af96-48a1-8168-ec8e2e5487a9",
  "guestIds" : [ {
    "guestId" : "g4"
  } ]
}
```

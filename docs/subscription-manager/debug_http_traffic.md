---
title: Debugging of HTTP traffic
---
{% include toc.md %}


Introduction
============

When you want to watch communication between RHSM clients (subscription-manager, rhsm.service, virt-who, etc.) and Candlepin server, then you can use several complicated solutions (Wireshark, parsing logs of Candlepin server) and one simple solution that is introduced in this document.

Debug Environment Variables
---------------------------

Every RHSM application using `rhsm` Python package can set following environment variables:

* `SUBMAN_DEBUG_PRINT_REQUEST`
* `SUBMAN_DEBUG_PRINT_REQUEST_HEADER`
* `SUBMAN_DEBUG_PRINT_REQUEST_BODY`
* `SUBMAN_DEBUG_PRINT_RESPONSE`

When you set these environment to any value (it can be `1` or `true` or anything else), then client application using rhsm module will start to print informations to standard output about HTTP requests.

NOTE: this functionality was introduced in RHEL8.3 in subscription-manager-1.27.11-1

### SUBMAN_DEBUG_PRINT_REQUEST

When you set this environment variable: `export SUBMAN_DEBUG_PRINT_REQUEST=1`, then you can get following output subscription-manager:


```
[root@localhost ~]# subscription-manager version

Making request: GET /candlepin/

Making request: GET /candlepin/status

server type: Red Hat Subscription Management
subscription management server: 3.1.21-1
subscription management rules: 5.41
subscription-manager: 1.28.3-1.git.1.21e89c8.fc32
```

As you can see subscription-manager prints not only usual output, but there are all HTTP requests.

### SUBMAN_DEBUG_PRINT_REQUEST_HEADER

When this environment is set using: `export SUBMAN_DEBUG_PRINT_REQUEST_HEADER=1`, then HTTP headers are also printed to standard output. Example:

```
[root@localhost ~]# subscription-manager version

Making request: GET /candlepin/ {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': '09214a14cb7147d2a3597ae2f04097b3', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32', 'Content-Length': '0'}

Making request: GET /candlepin/status {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': '09214a14cb7147d2a3597ae2f04097b3', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32', 'Content-Length': '0'}

server type: Red Hat Subscription Management
subscription management server: 3.1.21-1
subscription management rules: 5.41
subscription-manager: 1.28.3-1.git.1.21e89c8.fc32
```

### SUBMAN_DEBUG_PRINT_REQUEST_BODY

When this environment variable is set, then body of HTTP request is printed.

```
[root@localhost ~]# subscription-manager register --username admin --password admin --org admin

...

Making request: POST /candlepin/consumers?owner=admin {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': '8ccc84b060a14fca9ebbc3deb2c2d058', 'Authorization': 'Basic YWRtaW46YWRtaW4=', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32'} {"type": "system", "name": "localhost", ... }
```

### SUBMAN_DEBUG_PRINT_RESPONSE

When this environment variable is set, then response from Candlepin server is printed

```
[root@localhost ~]# subscription-manager version

Making request: GET /candlepin/ {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': 'a90da8ffd1304846973da3e51c0bafc7', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32', 'Content-Length': '0'}

200 {'Server': 'Apache-Coyote/1.1', 'x-candlepin-request-uuid': '8d4583a9-2557-49db-84d3-03c652757654', 'X-Version': '3.1.21-1', 'Content-Type': 'application/json', 'Transfer-Encoding': 'chunked', 'Date': 'Thu, 24 Sep 2020 09:18:22 GMT'}
[ {
  "rel" : "activation_keys",
  "href" : "/activation_keys"
}]

Making request: GET /candlepin/status {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': 'a90da8ffd1304846973da3e51c0bafc7', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32', 'Content-Length': '0'}

200 {'Server': 'Apache-Coyote/1.1', 'x-candlepin-request-uuid': 'f10df173-9a70-4bf5-b803-ba2b5b8e0180', 'X-Version': '3.1.21-1', 'Content-Type': 'application/json', 'Transfer-Encoding': 'chunked', 'Date': 'Thu, 24 Sep 2020 09:18:22 GMT'}
{
  "mode" : "NORMAL",
  "modeReason" : null,
  "modeChangeTime" : null,
  "result" : true,
  "version" : "3.1.21",
  "rulesVersion" : "5.41",
  "release" : "1",
  "standalone" : true,
  "timeUTC" : "2020-09-24T09:18:22+0000",
  "rulesSource" : "default",
  "managerCapabilities" : [ "instance_multiplier", "derived_product", "vcpu", "cert_v3", "hypervisors_heartbeat", "remove_by_pool_id", "syspurpose", "insights_auto_register", "storage_band", "cores", "hypervisors_async", "org_level_content_access", "guest_limit", "ram", "batch_bind" ]
}
```

Scripts
-------

It is good to create two scripts for switching debug prints on and off.

### Script for switching on

The script could look like this and can be saved in e.g. `~/bin/debug_subman_set.sh`

```bash
#!/bin/bash

export SUBMAN_DEBUG_PRINT_REQUEST=1
export SUBMAN_DEBUG_PRINT_REQUEST_HEADER=1
export SUBMAN_DEBUG_PRINT_REQUEST_BODY=1
export SUBMAN_DEBUG_PRINT_RESPONSE=1
```

It is worth to mention that you have to execute this script using `source` command:

```bash
source ~/bin/debug_subman_set.sh
```

You have to use `source`, because you want to set environment variables in current shell.

### Script for switching off

Script for switching off could look like this:

```bash
#!/bin/bash

unset SUBMAN_DEBUG_PRINT_REQUEST
unset SUBMAN_DEBUG_PRINT_REQUEST_HEADER
unset SUBMAN_DEBUG_PRINT_REQUEST_BODY
unset SUBMAN_DEBUG_PRINT_RESPONSE
```

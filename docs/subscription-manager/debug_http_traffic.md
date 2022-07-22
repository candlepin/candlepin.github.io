---
title: Debugging of HTTP traffic
---
{% include toc.md %}


Introduction
============

You can watch network communication between RHSM clients (subscription-manager, rhsm.service, virt-who, etc.) and the Candlepin server in several ways:

* by using Wireshark,
* by reading Candlepin logs,
* by setting environment variables listed below.

Debug Environment Variables
---------------------------

Every RHSM application using `rhsm` Python package can set following environment variables:

* `SUBMAN_DEBUG_PRINT_REQUEST`
* `SUBMAN_DEBUG_PRINT_REQUEST_HEADER`
* `SUBMAN_DEBUG_PRINT_REQUEST_BODY`
* `SUBMAN_DEBUG_PRINT_RESPONSE`
* `SUBMAN_DEBUG_TCP_IP`

When you set these environment variables (`1`, `true`, ...), the client application using rhsm module will start to print informations to standard output about HTTP requests. Subscription-manager currently considers all non-empty variables as `True`, but that may change in the future. We recommend unsetting these variables by passing empty string or by deleting the variable from the environment completely.

NOTE: This debugging functionality was introduced in RHEL8.3 in subscription-manager-1.27.11-1.

NOTE: Setting these values will disable subscription-manager's progress messages, which display the traffic in user friendly way.

### SUBMAN_DEBUG_PRINT_REQUEST

When you set this environment variable (`export SUBMAN_DEBUG_PRINT_REQUEST=1`), you get following output:

```
[root@localhost ~]# subscription-manager version

Making request: GET /candlepin/

Making request: GET /candlepin/status

server type: Red Hat Subscription Management
subscription management server: 3.1.21-1
subscription management rules: 5.41
subscription-manager: 1.28.3-1.git.1.21e89c8.fc32
```

As you can see, subscription-manager does not only print its usual output, but all HTTP requests as well.

### SUBMAN_DEBUG_PRINT_REQUEST_HEADER

When you set `export SUBMAN_DEBUG_PRINT_REQUEST_HEADER=1`, HTTP headers are also printed to standard output:

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

With this environment variable the body of a HTTP request is printed:

```
[root@localhost ~]# subscription-manager register --username admin --password admin --org admin

...

Making request: POST /candlepin/consumers?owner=admin {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': '1.28.3-1.git.1.21e89c8.fc32', 'Accept-Language': 'cs-cz', 'X-Correlation-ID': '8ccc84b060a14fca9ebbc3deb2c2d058', 'Authorization': 'Basic YWRtaW46YWRtaW4=', 'User-Agent': 'RHSM/1.0 (cmd=subscription-manager) subscription-manager/1.28.3-1.git.1.21e89c8.fc32'} {"type": "system", "name": "localhost", ... }
```

### SUBMAN_DEBUG_PRINT_RESPONSE

When this environment variable is set, all responses from the Candlepin server are printed:

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

### SUBMAN_DEBUG_TCP_IP

By setting this variable you can display connection information:

```
[root@localhost ~]# subscription-manager version

<ssl.SSLSocket fd=4, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=6, laddr=('10.40.193.205', 33504), raddr=('10.2.77.208', 443)>
Making (no auth) request: subscription.rhsm.stage.redhat.com:443 GET /subscription/ {'Content-type': 'application/json', 'Accept': 'application/json', 'x-subscription-manager-version': 'PKG_VERSION', 'X-Correlation-ID': 'd508c590224848b680cdd9b0d3d0d92a', 'Accept-Language': 'en-gb', 'User-Agent': 'RHSM/1.0 (cmd=subscription_manager.py) subscription-manager/PKG_VERSION', 'Content-Length': '0'}

...
```

CLI helper for enabling debugging
---------------------------------

To make debugging faster, you can create a function in your `.bashrc` file that will set the variables for you:

```bash
function subscription-manager-debug() {
    if [[ $1 == "on" || $1 == "all" ]]; then
        export SUBMAN_DEBUG_PRINT_REQUEST=1
        export SUBMAN_DEBUG_PRINT_REQUEST_HEADER=1
        export SUBMAN_DEBUG_PRINT_REQUEST_BODY=1
        if [[ $1 == "all" ]]; then
            export SUBMAN_DEBUG_PRINT_RESPONSE=1
            export SUBMAN_DEBUG_TCP_IP=1
        fi
    elif [[ $1 == "off" ]]; then
        unset SUBMAN_DEBUG_PRINT_REQUEST
        unset SUBMAN_DEBUG_PRINT_REQUEST_HEADER
        unset SUBMAN_DEBUG_PRINT_REQUEST_BODY
        unset SUBMAN_DEBUG_PRINT_RESPONSE
        unset SUBMAN_DEBUG_TCP_IP
    else
        echo "subscription-manager-debug [ on | all | off ]"
        echo "  on   request headers & bodies"
        echo "  all  request headers & bodies, responses, TCP/IP connection"
        echo "  off  disable all"
        return 1
    fi
}
complete -W "on all off" subscription-manager-debug
```

By placing this function into `.bashrc` you'll make it available every time you open a shell. Alternatively you can place it to separate bash file (`~/bin/subman-debug.sh`) and `source` it before using it.

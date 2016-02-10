---
categories: usage, developers
title: Migration Validation Tool
---
{% include toc.md %}

# Overview

The Candlepin Migration Validation (cmv) utility is a simple tool for verifying the integrity of a
Candlepin deployment by taking snapshots before performing a, potentially destructive, operation,
and then verifying it afterwards. If cmv detects any descrepancies, it will display a warning or
error, depending on the perceived severity of the issue.

As the cmv tool uses the Candlepin API to perform all of its operations, it can also be used to
verify/identify any API changes between versions.



## General Usage

Usage of the cmv tool is a two-step process: collecting a snapshot before performing a migration (or
any other potentially destructive operation), and then verifying the snapshot afterwards.

__Note__: Candlepin must be deployed and started before issuing any cmv commands. While using cmv, try
to limit the usage of the Candlepin server, as concurrent modification could lead to mismatches in
the snapshots and cause the verification to generate false positives.


### Taking a Snapshot
Taking a snapshot is as simple as providing the ```snapshot``` command:

```~/devel/candlepin/server(master) $ ./bin/cmv snapshot```

cmv will begin pulling information for each registered organization, generating the following
output for each:

```
Fetching data for org "donaldduck"...
  Retrieving consumers...      done.
  Retrieving pools...          done.
  Retrieving subscriptions...  done.
  Retrieving products...       done.
```

By default, the snapshot data will be saved to "snapshot.zip", though this can be specified with the
```--file [FILE]``` option. Additionally, if only specific organizations are of interest, they may
be specified after the command:

```~/devel/candlepin/server(master) $ ./bin/cmv --file donaldduck.zip snapshot donaldduck```



### Verifying a Snapshot
Verifying a snapshot is just as easy. After performing the migration, simply run cmv with the
```verify``` command:

```~/devel/candlepin/server(crog/multiorg) $ ./bin/cmv verify```

If all went well with the migration, cmv will output a general success message:

```Deployment successfully verified against snapshot: snapshot.zip```

However, if cmv detected a change in the data, warnings or errors will be displayed:

```
Deployment failed validation against snapshot snapshot.zip with 2 messages

WARNING: Key "productId" does not exist in deployment data at: orgs[donaldduck].pools[8a8d09d64dd3f154014dd3f21ed71fa5].productAttributes[arch].productId
Expected: awesomeos-docker

ERROR: Value mismatch at: orgs[donaldduck].pools[8a8d09d64dd3f154014dd3f21ed71fa5].productAttributes[arch].created
Expected: 2015-06-08T16:12:49.751+0000
Actual:   2015-06-08T16:12:24.827+0000
```

As with the ```snapshot``` command, the snapshot file used for verification can be specified with
the ```--file [FILE]``` option, and specific organizations may be provided:

```~/devel/candlepin/server(master) $ ./bin/cmv --file donaldduck.zip verify donaldduck```



### Filtering Verification Messages
When cmv generates a validation message may indicate an issue with the migration/operation (which
may or may not be solved by reverting and retrying). In some cases, though, these issues may be
expected, unnecessary noise. In such an event, we can exclude those fields from the verification
report with the ```--exclude [FIELD]``` option:

```~/devel/candlepin/server(crog/multiorg) $ ./bin/cmv --exclude orgs.pools.productAttributes.productId --exclude orgs.pools.productAttributes.created verify```

which results in:

```Deployment successfully verified against snapshot: snapshot.zip```

Conversely, if we're only interested in certain fields, we can include them to, implicitly, exclude
everything else:

```~/devel/candlepin/server(crog/multiorg) $ ./bin/cmv --include orgs.pools.productAttributes.productId verify```

which gives us:

```
Deployment failed validation against snapshot snapshot.zip with 1 messages

WARNING: Key "productId" does not exist in deployment data at: orgs[donaldduck].pools[8a8d09d64dd3f154014dd3f21ed71fa5].productAttributes[arch].productId
Expected: awesomeos-docker
```

Include and exclude filters can be combined in any way, with the most explicit filters "winning."
For instance, excluding _orgs.pools_ and including _orgs.pools.productAttributes_ will exclude all
properties of _orgs.pools_ except for _productAttributes_.



## CMV Options and Commands
```
Usage: cmv [options] <command> [org1 [, org2, [, org3...]]]

Options:
        --username [USER]            Username to connect as; defaults to "admin".
        --password [PASSWORD]        Password to authenticate the user as; defaults to "admin".
        --server [SERVERNAME]        Server name FQDN; defaults to "localhost"
        --port [PORTNUM]             Port number for the Candlepin server; defaults to 8443
        --context [CONTEXT]          Context to use; defaults to "candlepin"
        --uuid [UUID]                UUID to use; defaults to nil
        --nossl                      Do not use SSL; defaults to false
        --trusted                    User should be trusted; defaults to false
    -f, --file [FILE]                The snapshot file to read/write; defaults to "snapshot.zip"
    -x, --exclude [EXCLUDE]          A field to ignore during verification; may be specified more than once
    -i, --include [INCLUDE]          A field to examine during verification, overriding any excludes; may be specified more than once
        --verbose                    Enable Verbose Logging
    -?, --help                       Displays command and option information
    -c, --commands                   Displays the available commands

Commands:
  snapshot          Creates a snapshot of the products, content and pools for the specified org(s)
  verify            Verifies the current data for the specified org(s) matches the last/given snapshot
```


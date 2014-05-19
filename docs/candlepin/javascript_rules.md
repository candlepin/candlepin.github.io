---
title: JavaScript Rules
---
{% include toc.md %}

Candlepin uses a Javascript rules file to encapsulate business logic around what consumers can use a given pool, which pools are the best fit to auto-subscribe for a given consumer, and what a consumer's entitlement status is. (red green yellow)

# How It Works
The Candlepin RPM contains a copy of the rules file when that package was
generated. Rules files can be uploaded explicitly by a super admin using POST
/rules, though this is generally rarely used.

## Manifests
Rules files are included in all manifests, and imported on downstream Candlepin
servers when the manifest is imported, provided the included version is
compatible and newer than what the server currently has. See versioning section
below.

If you examine a manifest zip file, you will see the new rules file in the
rules2 directory, the current filename is rules.js.

You will also see rules/default-rules.js, this is a legacy rules file now
deprecated, but left in the manifests to prevent breakage when new manifests
are imported on older Candlepin servers.

# Versioning
The new rules.js file contains a version in the first line of the file. The
major portion of the version number indicates overall compatability for the
Candlepin server. Any time we change something major, usually passing
additional data in or removing something we pass in, the major version number
must increment. This will prevent any older Candlepin server from trying to use
a rules file that will break.

The minor version number will be incremented on any change to the rules that does not break API compatability.

On import, the Candlepin server will only import an incoming rules file if the
major version number matches exactly, and if the minor version number is
greater than or equal to what it has already. We do not want lesser minor
version numbers as we can assume we already have newer rules. This prevents
situations where the rules can revert to older files depending on the order
manifests were generated vs imported in a multi-org deployment.

Once a rules file is uploaded, it is stored in the database replacing anything
that was there before. On every server start up, we treat the load from the
database as if it were an import, allowing us to not use older or incompatible
rules from the database if the Candlepin RPM has been upgraded and now carries
newer rules, or a new rules API major version number.

Developers should strive to change the major version number as little as
possible, as this effectively disables import of new rules on all Candlepin
servers in the wild until they upgrade.

# Developer Notes
* Bump the minor version number of the rules.js file on any change to the file.
  Bump the major if we add/remove/change something that will not work on older
  Candlepin servers. Try to avoid doing this whenever possible.
* Do not use "for each" in Javascript rules, this has been [deprecated](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Statements/for_each...in).

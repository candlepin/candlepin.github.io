---
title: Candlepin Database Validation
---
{% include toc.md %}

# Overview

As part of a plethora of changes made in Candlepin 2.0, the product model changed from one where product and
content data existed globally to one where this data is now per-org, as well as tighter restrictions on
product and content referencing. This comes with a rather hefty migration of old product data to the new model
when upgrading from a pre-2.x version of Candlepin. Along with that migration is a bit of validation to ensure
the database isn't in a bad state before attempting such a lengthy migration process.



# What is Validated?

The migration validation primarily looks for objects referencing non-existent or unresolvable products and
content. At the time of writing, the following objects are checked:

1. Pool => Product
1. Subscription => Product
1. Environment => Content

When the validation is run, it will check all of the above objects for any references to a product or content
that appears to no longer exist. If it finds one, an error message will be output with the ID of the
referencing object and the ID of the invalid product or content.



# Running the Validation

## Candlepin 2.1 and later

From Candlepin 2.1 on, the validation can be performed by passing the --validate flag to cpdb. This will run
the validation checks and output any errors it finds:

```
$> cpdb --validate
Configuring PostgreSQL with JDBC URL: jdbc:postgresql:candlepin
Validating Candlepin database
...
```

## Candlepin 2.0 and earlier

To validate a Candlepin deployment prior to 2.0, the validation tools must be executed directly by invoking
Liquibase with the proper parameters and fetching the custom task files from Candlepin 2.1 and newer.

Unfortunately, as this validation tool did not exist prior to version 2.1, they need to be downloaded and
unpacked manually. The standard pre-2.1 validation package can be obtained
[here]({{ site.baseurl }}/binaries/cpvalidation.zip). Once unpacked, the validation can be manually triggered
with the following command:

```
$> liquibase --classpath=/usr/share/java/postgresql-jdbc.jar:<classpath> --changeLogFile=changelog-validate.xml \
--driver=org.postgresql.Driver --url=jdbc:postgresql:candlepin --username=<db_username> --password=<db_password> \
--logLevel=severe migrate
```

In the above command, the following variables need to be filled in:

- <classpath>: the path where the changelog files can be found as well as the class files for the custom
    validation tasks. For example, if the validation package is unpacked to user's home directory, this should
    be set to "/home/user/cpvalidation". Note that shortcuts and macros are not processed by Liquibase, so
    "~/cpvalidation" won't work here.
- <db_username>: The username to be used when connecting to the Candlepin database. This is typically just
    "candlepin"
- <db_password>: The password to be used when connecting to the Candlepin database. This will vary depending
    on the system's configuration

Additionally, it may be necessary to change the value for the --driver and --url parameters as appropriate if
the system to validate is not backed by a PostgreSQL database, or the database is running on another system.

Using the standard validation package above, unpacked to the user's home directory, on a typical system
configuration, the validation execution will look like the following:

```
$> liquibase --classpath=/usr/share/java/postgresql-jdbc.jar:/home/user/cpvalidation --changeLogFile=changelog-validate.xml \
--driver=org.postgresql.Driver --url=jdbc:postgresql:candlepin --username=candlepin \
--logLevel=severe migrate
```



# Understanding the Output

When an error occurs, an error message will be written to the console output indicating which org had
failures, and which object has the bad reference.

```
Pool "<pool_id>" references an unresolvable product: <bad_product_id>
Subscription "<sub_id>" contains a null or empty product reference
...
Org <org_name> (<org_id>) failed data validation
...
One or more orgs failed data validation
```

Starting from the bottom, the most obvious error will be the final line, indicating that there are more error
messages above. Scroll back a bit and you'll see an org-specific data validation error. Scroll back a bit
further and you'll see specific error messages. Because of the order these messages are output, the hierarchy
is built backward. The "org failed data validation" message will follow the specific messages for that
organization.

For the specific object reference messages, there are only two types of errors:

- <object> references an unresolvable (product|content): bad_product_or_content_id
- <object> contains a null or empty (product|content) reference

The first type indicates that the object in question is attempting to reference *something*, but that
something doesn't exist. This is likely caused by a product or content being deleted without cleaning up the
whole object graph (as CP 0.9 wasn't as strict about its references).

The second type indicates that the object isn't attempting to reference anything. This primarily only occurs
on pools and subscriptions, and suggests the data in the database has been corrupted or manually updated.



# Fixing the Issues

Unfortunately, there isn't a good one-size-fits-all type of fix for these errors. For some product or content
references, simply deleting the referencing object will be acceptable. For others, not so much.

In the case of the unresolvable reference, the ID may be clear enough that restoring the referenced object can
be done, or the reference can be updated to point to an existing product or content that matches. However, in
cases where the reference is missing entirely, an educated guess will need to be made based on remaining data
in the object itself.


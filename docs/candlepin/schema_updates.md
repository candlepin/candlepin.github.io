---
title: Database Schema Updates
---
{% include toc.md %}

# Candlepin Database Schema Updates
We are using the [liquibase](http://www.liquibase.org) database
refactoring tool for updating the candlepin database. Changes are represented
by XML files containing instructions on the changes to apply. Liquibase keeps
track of what has been applied and what hasn't, and is capable of managing a
database even when branches are being merged together.

## Create vs Update
We maintain two XML files, one for creating a fresh database, one for updating
any deployed database starting from candlepin 0.5.26. 

_changelog-create.xml_ contains all instructions to create the latest database
schema. The schema for 0.5.26 is directly in this file, but all future updates
will be in their own XML changeset file, and referenced in both
changelog-create and changelog-update.

_changelog-update.xml_ contains all instructions to update any database since
candlepin 0.5.26.

Because both create and update reference all future changes, this will allow us
to create new databases and later update them, without liquibase getting
confused about what has been applied and what hasn't.

## Authoring A Database Change
1. Edit the Java classes and Hibernate annotations as before.
1. Run the buildr task to generate a timestamped changeset template and include it in the relevant changelogs:
   (it is assumed that candlepin is checked out under $HOME/src/)

   ```
   $ cd $HOME/src/candlepin/server
   $ buildr "changeset: short-description-for-filename-goes-here"
   ```
1. Edit the resulting file to perform the actual changes. The liquibase
   documentation on [refactoring commands](http://www.liquibase.org/documentation/changes) and
   [changesets](http://www.liquibase.org/documentation/changeset) may be useful here.
1. Test applying your change: (may have to adjust this command slightly for your system)

   ```
   $ liquibase --driver=org.postgresql.Driver --classpath=$HOME/src/candlepin/server/src/main/resources:$HOME/src/candlepin/server/target/classes:/usr/share/java/postgresql-jdbc.jar --changeLogFile=$HOME/src/candlepin/server/src/main/resources/db/changelog/changelog-update.xml --url="jdbc:postgresql:candlepin" --username=candlepin --password="" update
   ```
1. Test rolling back your changes. If using the standard liquibase supported
   instructions for your change (as opposed to doing raw SQL), we do not need
   to author explicit rollback instructions, liquibase can figure these out for
   us in most cases.

   ```
   $ liquibase --driver=org.postgresql.Driver --classpath=$HOME/src/candlepin/server/src/main/resources:$HOME/src/candlepin/server/target/classes:/usr/share/java/postgresql-jdbc.jar --changeLogFile=$HOME/src/candlepin/server/src/main/resources/db/changelog/changelog-update.xml --url="jdbc:postgresql:candlepin" --username=candlepin --password="" rollbackCount 1
   ```
1. git add, and commit.

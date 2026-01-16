---
title: Developers
---
{% include toc.md %}

This page contains a variety of information for those intending to work on Candlepin and its associated sub-projects.

# Code Style
Our canonical reference for code style is the `config/checkstyle/checkstyle.xml` file
which stores all the Checkstyle configuration.

### Checkstyle
* See instructions [here](checkstyle.html).

Also see the [Java Coding Conventions](java_coding_conventions.html)

### Python
For Python, stick to the guidelines in [PEP 8](https://peps.python.org/pep-0008/).
Also, run `make stylish` to run pep8, pyflakes, pyqver, rpmlint, and a few
subman specific code checks.

### C
For C, run this on your code before you commit: `indent -linux -pcs -psl -ci8
-cs -cli8 -cp0 yourawesomefile.c`. Note that you may need to double-check that
the "\*" is on the right line, and feed in arguments to indent as appropriate.

# Committing Code Changes

## Commit Messages
When writing commit messages, the goal is to have a summary that describes the changes as a whole, and details
including specifics about the change.

The first line of a commit message is used as the title for many things, including both our build changelogs
and the default PR title. Commit titles are limited to 70 characters and will be automatically truncated or
word-wrapped by tooling the processes commit messages.

For commits originating from jira issues, the beginning of the
commit title should be the ID of that issue followed by a colon (e.g. CANDLEPIN-XYZ: ).

The body of the commit message should consist of one or more bulleted items indicating specifics about the
change, such that a reader unfamiliar with the specifics of the change can get a rough understanding of the
change and developer intent without needing to look at the code. Each line of the body should also try to stay
within the 70 characters limit.

Commit messages are used for generating changelogs when tagging builds. It may seem pedantic but when you need
to process a few hundred lines it's very helpful if they're typo free, changelog friendly, and have the
originating task automatically detected.

A general git guide can be found in the [Pro Git book](https://git-scm.com/book/en/v2).

### Commit message format
```text
[{jira_id}:] commit title & summary of changes (70 char limit)
- bulleted list of specific changes
- change two
- change three
```

### Examples
```text
Added same-ID entity version collision resolution

  - The versioned entity update logic will now clear the entity
    version for an existing entity on collision when the colliding
    entities have the same entity ID
```

```text
Added support for the device_auth capability and status

  - Added support for the device_auth capability
  - Added new fields to the status DTO for indicating OAuth2
    device auth details (realm, url, client_id, and scope)
  - Updated keycloak flows to also populate the device auth
    fields and capabilities
```

```text
CANDLEPIN-1234: Fixed attribute storage issue causing version collisions

  - Fixed a bug with null-versioned product attributes causing
    version collisions due to being used in the version calculation
    before being silently discarded during entity persistence
  - Null-valued attributes are now silently discarded at the API
    layer to retain the current behavior
  - Product entities will no longer accept null values for product
    attributes, as Hibernate throws them out anyway
```

### Important Notes
 * Please be sure that when committing code, you have your git author info set up correctly, and that you are
   working as the correct user.
 * Take a few seconds before committing to ensure that your commit messages follow the correct format, and are
   typos free.

## Pull/Merge Request Messaging
Pull-request (PR) titles should generally use the commit title for PRs containing only a single commit,
but with the additional fields. In the case of a PR containing multiple commits, the PR title should be
updated to encapsulate the entirety of the work or changes made by all of the commits.

Additionally, indicating the intended branch in the PR title helps readers quickly identify the context of the
changes, and confirms that the target branch matches the author’s intent. This is not strictly required, but
can be helpful to reviewers.

For complicated PRs or changes that involve complicated manual testing steps, the author should add a comment
which includes information needed to perform manual testing and/or verification steps, as well as any other
additional information needed to properly contextualize the changes contained in the PR.

### Pull Request Title Formatting
#### General Format
`[{branch_code}] {jira_id}: {pr_title}`

Where:
 * **branch_code**<br/>
   Version of the target branch (3.2, 4.0, 4.1, ‘M’ for main, ‘F’ for feature branches’, or ‘POC’ for proof of concepts that are not supposed to be merged)
  * **jira_id**<br/>
   The ID of the Jira task associated with the change (e.g. CANDLEPIN-1234); should be available most of the time, except for PRs with minor changes not tracked in a jira issue
 * **pr_title**<br/>
   The title of the PR; should usually match the commit summary 1:1 unless the PR contains multiple commits,
   in which case it should be a summary of all changes

### Examples
#### Titles
 * [M] CANDLEPIN-1234: Updated code to not fail when it should work
 * [4.6] CANDLEPIN-4096: Added new utility to do a thing
 * [POC] CANDLEPIN-1117: Migrate to Jakarta EE

#### Example PRs
 * Single-commit PR with simple change on the main branch:<br/>
   <https://github.com/candlepin/candlepin/pull/5319>

 * Single-commit PR with a complex change on the main branch:<br/>
   <https://github.com/candlepin/candlepin/pull/5336>

 * Single-commit PR with a complex change on a feature branch:<br/>
   <https://github.com/candlepin/candlepin/pull/5332>

 * Multi-commit, prototype/PoC PR:<br/>
   <https://github.com/candlepin/candlepin/pull/5304>



# Testing
Testing is extremely important for the team. We have a variety of test suites
on the go, all of which should be kept passing before you commit to any given
codebase.

1. Candlepin
   * Java unit tests: Standard JUnit tests which can be run from within Eclipse or from the CLI.

     ```console
     $ ./gradlew test
     ```

     A specific suite can be run with:

     ```console
     $ ./gradlew test --tests EntitlementCuratorTest
     ```
   * Specification tests:

     ```console
     $ ./gradlew spec
     ```
   * The safest bet, in addition to spec, is to run check (includes all lint tasks, test, validate_translation) before committing:

     ```console
     $ ./gradlew  check
     ```

## Mocks
When possible, we try to leverage mocks in unit tests to skip
complicated/costly setup of objects we're not interested in, and instead just
focus on testing the component we are interested in. This is a bit of an art
form in itself and can be quite tricky to get the hang of, and when it goes
wrong you can end up with an un-maintainable mess. Look for good examples,
experiment, chat with the team, and in general just try to leverage this when
possible. We're all still learning how this works. :)

In the Java unit tests this is accomplished with [Mockito](https://site.mockito.org/).

In subscription-manager and python-rhsm we use the python-mock module: <http://www.voidspace.org.uk/python/mock/>

# Architecture Gotchas
Candlepin can be a confusing beast. Some pointers that may help to understand how things work and why they are the way they are.

## Service Adapters
Central to Candlepin's design is the use of adapters to abstract services which
may or may not be provided by Candlepin components. Objects such as
Subscriptions, Products, and Users all may live in external systems depending
on the deployment.

Tips:

 * Don't directly query the curators for these objects, use the service adapters instead.
 * Don't relate hibernate objects we *do* store in our database directly to these objects. You'll have to store the ID instead.

## Subscriptions vs Pools
These two objects are almost the exact same thing. They both exist because we
may not be the canonical source for Subscription data. As such we use the
Subscription service adapter to query subscription data, and use this to
create/update/delete our own Pool objects (which are always in our database).
The Pool's are then used to track consumption.

## Reading SSL Data for Debugging
See [the debugging with wireshark page](debugging_with_wireshark.html)

# Tips

## Auto-Generating candlepin.conf
The Candlepin deploy script can generate `candlepin.conf` for you, which is useful when switching
between databases/environments. See [Developer Deployment](developer_deployment.html) for the `-a`
option, and see [the AutoConf page](auto_conf.html) for legacy Buildr-based workflows.

## Backup / Restore A Database
It can be helpful for developers to save a postgresql database for later use
particularly when they're loaded with a complex or large amount of data.

```console
$ pg_dump -U candlepin candlepin > candlepindb.sql
```

To restore an old database:

```console
$ sudo systemctl stop tomcat
$ dropdb -U candlepin candlepin && createdb -U candlepin candlepin
$ psql -U candlepin candlepin < ~/src/candlepin/candlepindb.sql
$ ./bin/deployment/deploy -g -t -a
```

## Debugging with Tomcat
To enable remote debugging in Tomcat, you must pass the JVM values telling it to enable JDWP.

1. Open `/etc/tomcat/tomcat.conf`
1. Add the following to the `CATALINA_OPTS` variable:

   ```
   -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000 # for Java 11+
   ```
   Now you will be able to connect a debugger to port 8000.

   The `-Xdebugger -Xrunjdwp` version of enabling the debugger has been
   [deprecated as of Java 5](http://docs.oracle.com/javase/6/docs/technotes/guides/jpda/conninv.html).
   Use `-agentlib` instead.
   {:.alert-notice}

## Building RPMs with Tito
Candlepin uses Tito to build the rpms, see [here](building_rpms_with_tito.html).

## Logging SQL queries and parameters
To see how to debug hibernate SQL queries see [the logging page](logging.html)

## Analyzing PostgreSQL Performance
```sql
CREATE FUNCTION pg_temp.sortarray(int2[]) returns int2[] as '
  SELECT ARRAY(
      SELECT $1[i]
        FROM generate_series(array_lower($1, 1), array_upper($1, 1)) i
    ORDER BY 1
  )
' language sql;

  SELECT conrelid::regclass
         ,conname
         ,reltuples::bigint
    FROM pg_constraint
         JOIN pg_class ON (conrelid = pg_class.oid)
   WHERE contype = 'f'
         AND NOT EXISTS (
           SELECT 1
             FROM pg_index
            WHERE indrelid = conrelid
                  AND pg_temp.sortarray(conkey) = pg_temp.sortarray(indkey)
         )
ORDER BY reltuples DESC
;
```

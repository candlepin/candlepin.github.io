## Using Mead

By Alex Wood <!-- .element class="caption" -->

Copyright 2015 <!-- .element class="caption" -->

Licensed Under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)

<!-- .element class="caption" -->

----
# The Old Way

* Candlepin was prohibited from including any dependencies directly
* Required dependencies were installed via RPM into `/usr/share/java`
* Candlepin's RPM install symlinked required dependencies into `WEB-INF/lib`

----
# The Old Way: Common Problems

* The spec file required a separately maintained Ant script to run during the
  build stage.  (Buildr is unpackaged and would require Ruby anyway)
* Adding a new dependency or updating to a recent version were nigh impossible
  * Required a pre-existing RPM for both RHEL 6 and RHEL 7 of the dependency
  * No RPM?  We had to build our own.  Not trivial for large or complex
    libraries
* A user inadvertently updates a dependency RPM with a version that isn't
  backwards compatible.  Candlepin stops working

----
# The New Way: Mead

* Mead is a Maven-based build system for Java applications
* Has an offline Maven repository that we can use to build against
* Operates on SCM URLs and not source tarballs
* Prepends a new step onto the RPM building process
  * The class files are compiled **before** rpmbuild ever even runs and included
    in the SRPM
  * The result is an RPM that cannot easily be rebuilt from source.  These RPMs
    are also called *wrapper RPMs*

----
# Basic Process

* Mead receives an SCM URL, checks out the code, and resets to a given ref
  (usually a tag)
* Mead runs a Maven command against the repository.  The user has some control
  over the arguments Maven receives
* Mead takes a Cheetah template of a spec file and renders it based on data
  created by the build.  E.g. it inserts file names that the build created
* The rendered spec file references the newly built JAR/WAR files.
* Mead runs `rpmbuild` to build a SRPM that contains the rendered spec and the
  JAR/WAR files
* Mead runs `rpmbuild` to build an RPM.  We may do things in the `%install`
  macro, but no actions are necessary in the `%build` macro since everything is
  already built

----
# Concepts: The Offline Repository

* Items must be imported into the Mead repository before building.  The Maven
  build is configured to run without accessing the network
* Importing items is very tedious because Maven artifacts always have a huge web
  of dependencies

----
# Concepts: The SCM URL

* The SCM URL takes the format of git://example.com/**repo**?**subdirectory**#**gitref**
* Protocol: must use git for an anonymous checkout
* Host: must be on a whitelist
* Repo: name of the repo to check out
* Subdirectory: (optional) a subdirectory to descend into.  All further steps
  will occur in the context of the subdirectory
* Gitref: Usually a tag, but you can use a SHA-1 too

----
# Concepts: The Template

* Written in [Cheetah](http://www.cheetahtemplate.org/)
* Several variables are provided during rendering
  * `$name` - corresponds to `groupId-artifactId`
  * `$version`
  * `$release`
  * `$artifacts` - A hash of the Maven generated artifacts with the file
    extensions as keys. For example: `{'.md5': 'my_project.jar.md5', '.jar':
    my_project.jar'}`
  * `$all_artifacts` - all Maven generated artifacts in a list (including MD5
    sums, pom files, etc).
  * `$all_artifacts_with_path` - all artifacts but with the full path to the
    artifact within the project


---
categories: developers
title: Building RPMs with Tito
---
{% include toc.md %}

# Building RPMs with Tito
Candlepin uses [tito](http://github.com/dgoodwin/tito/blob/master/README.mkd) to build the rpms.

## Configuration
Tito is configured by `rel-eng/tito.props` with user defined settings in `$HOME/.titorc`

The default Candlepin Tito config is as follows:

```ini
[globalconfig]
default_builder = spacewalk.releng.builder.Builder
default_tagger = spacewalk.releng.tagger.VersionTagger
```

You can change the default build location in `$HOME/.titorc`.
For example, you can change the RPMBUILD directory here.

```console
$ cat ~/.titorc 
RPMBUILD_BASEDIR=$HOME/mytitobuilddir
```

## Build Requires
Candlepin has a new set of build requirements solely for rpm building.
Candlepin now uses [ant](http://ant.apache.org) to build the rpm. This is
primarily because [buildr](http://buildr.apache.org) isn't yet packaged as an
[rpm](http://github.com/jmrodri/zspecs/tree/master/rubygem-buildr) and it
expects to have access to a external maven repo which isn't true in a build
environment like [koji](http://koji.fedoraproject.org/koji/).

 * tito - used to build the rpm
 * java >= 0:1.6.0 - since Candlepin is in Java :)
 * java-devel >= 0:1.6.0 - contains the Java compiler
 * ant >= 0:1.7.0 - used to build and package Candlepin
 * gettext - needed for the Candlepin [i18n](http://en.wikipedia.org/wiki/Internationalization_and_localization) work
 * [candlepin-deps](http://github.com/jmrodri/candlepin-deps/downloads) -
   flattened collection of jars required to build Candlepin. As time goes on,
   these will start to be packaged as rpms and added as proper `Requires:` and
   `BuildRequires:`.

Before you can build the Candlepin rpm using tito, you'll need to install the above packages:

```console
$ sudo yum install -y tito java java-devel gettext ant
$ sudo rpm -Uvh https://github.com/downloads/jmrodri/candlepin-deps/candlepin-deps-0.0.18-1.fc13.noarch.rpm
```

## Building using Tito
Once you have resolved the [#BuildRequires build requires] you can build the Candlepin rpm locally using `tito`.

### Latest tagged build
Want to build the latest tagged build? Simply run:

```console
$ tito build --rpm
```

Tito will then spew out the rpm output to the screen, no need to be alarmed this is normal.

```console
Checking for tag [candlepin-0.0.40-1] in git repo [ssh://git.fedorahosted.org/git/candlepin.git/]
Building package [candlepin-0.0.40-1]
Wrote: /tmp/candlepin-build/candlepin-0.0.40.tar.gz
Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.0C7UrZ
...
Successfully built: /tmp/tito/candlepin-0.0.40-1.src.rpm \
  /tmp/tito/noarch/candlepin-0.0.40-1.noarch.rpm \
  /tmp/tito/noarch/candlepin-tomcat5-0.0.40-1.noarch.rpm \
  /tmp/tito/noarch/candlepin-tomcat6-0.0.40-1.noarch.rpm \
  /tmp/tito/noarch/candlepin-jboss-0.0.40-1.noarch.rpm
```

### Test build
Sometimes you want to test your code changes in the rpm without pushing your changes to the public repo.
This is easy with `tito`. Simply commit your changes to your local git checkout, then build a test rpm.

```console
$ tito build --test --rpm
```

Tito will use the current git commit SHA1 and calculate the number of commits
since the last tagged build. This results in test rpms which are upgradable
removing the need to uninstall a test rpm before installing a new version.
Also, it allows upgrading to official releases since they will have a version
number higher than your test builds.

Here is an example of a test rpm: `candlepin-0.0.40-1.git.11.f05b8a5.src.rpm`.
The latest git commit is *f05b8a5* which is *11* commits since the last tag:
*candlepin-0.0.40-1*. 

## Other tito resources
 * [tito github repo](http://github.com/dgoodwin/tito)
 * [Tito introduction into Spacewalk](https://fedorahosted.org/spacewalk/wiki/Tito)
 * [Spacewalk release cycle using Tito](https://fedorahosted.org/spacewalk/wiki/ReleaseProcess)
 * [Building test rpms using Tito](https://fedorahosted.org/spacewalk/wiki/GitGuide#BuildingTestRPMs)

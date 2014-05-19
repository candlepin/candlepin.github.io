---
title: Common Problems
---
{% include toc.md %}

# Unable to Start Webapp
The Tomcat RPM likes to change permissions on install / upgrade, and leave the
directories unwritable by the tomcat process itself. This may surface in
cpsetup with an error like:

```console
Error running command: wget -qO- http://localhost:8080/candlepin/admin/init
```

Or when trying to do an import/export:

```console
Caused by: java.io.IOException: No such file or directory
        at java.io.UnixFileSystem.createFileExclusively(Native Method)
        at java.io.File.checkAndCreate(File.java:1716)
        at java.io.File.createTempFile(File.java:1804)
        at org.apache.james.mime4j.storage.TempFileStorageProvider.createStorageOutputStream(TempFileStorageProvider.java:104)
```

`cpsetup` now has some code to try and fix this, but essentially you need to
check for any dangling symlinks in /usr/share/tomcat6, and make sure the
directories are writable by the tomcat process:

```console
$ chmod g+x /var/log/tomcat6
$ chmod g+x /etc/tomcat6/
$ chown tomcat:tomcat -R /var/lib/tomcat6
$ chown tomcat:tomcat -R /var/lib/tomcat6
$ chown tomcat:tomcat -R /var/cache/tomcat6
```

Sometimes the no such file or directory error will originate from resteasy,
which indicates the tomcat temp directory does not exist. This can be corrected
with:

```console
$ mkdir /var/cache/tomcat6/temp
$ chown root:tomcat /var/cache/tomcat6/temp
$ chmod g+w /var/cache/tomcat6/temp
```

# RHEL 6 And java-1.5.0-gcj
We may have an issue with RHEL 6 and the Candlepin rpms. If your system is
using java-1.5.0-gcj after installing the Candlepin RPMs, switch to
java-1.6.0-openjdk instead. We're probably missing a requires on our rpm.

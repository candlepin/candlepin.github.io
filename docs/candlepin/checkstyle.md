---
title: Checkstyle
---
{% include toc.md %}

Candlepin uses [Checkstyle](http://checkstyle.sourceforge.net/) to ensure the
code remains as readable as possible. You can run checkstyle from both the
command line and from within [Eclipse](http://www.eclipse.org/).

## Command line
Run the following command: `./gradlew checkstyleMain checkstyleTest` and the results will be
printed out to your console. 

## Overriding Checkstyle
On occasion you will need to override Checkstyle.  For example, if you use
a JUnit Rule, JUnit requires that the Rule object be public which violates
our Checkstyle requirement that fields be private and use accessors.

To get around this false positive, you can tag your code with the
`@SuppressWarnings` annotation and provide the violated module as the
argument.  For example:

```java
@SuppressWarnings("checkstyle:visibilitymodifier")
@Rule
public ExpectedException ex = ExpectedException.none();
```

Of course, this requires that you know the name of the Checkstyle module that
the code is failing.  I do not currently have a fool-proof way of determining
the module.  Usually I look in the `project_conf/checks.xml` file and do a
little trial and error.

See more at the [Checkstyle documentation on SuppressWarnings
Holder](http://checkstyle.sourceforge.net/config_annotation.html).

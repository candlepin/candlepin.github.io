---
title: Checkstyle
---
{% include toc.md %}

Candlepin uses [Checkstyle](http://checkstyle.sourceforge.net/) to ensure the
code remains as readable as possible. You can run checkstyle from both the
command line and from within [Eclipse](http://www.eclipse.org/).

## Command line
Run the following command: `buildr checkstyle` and the results will be
printed out to your console.  If you would like a report, you can run the
`checkstyle:html` task.

## Eclipse integration
I followed the instructions on the eclipse-cs plugin page:
[http://eclipse-cs.sourceforge.net/downloads.html](http://eclipse-cs.sourceforge.net/downloads.html),
here they are with some added screenshots:

 1. In Eclipse, click `Help->Software Updates...`
 1. Click on `Add Site...`
 1. Enter `http://eclipse-cs.sf.net/update`
 1. Click the down arrow and choose Eclipse Checkstyle Plug-in 5.x (latest 5.x version is suitable)

    ![]({{ site.baseurl }}/images/checkstyle-eclipse.png)
 1. Click `Install...`
 1. Review, then click `Next>`

    ![]({{ site.baseurl }}/images/checkstyle-eclipse-review.png)
 1. Accept the license
 1. Click `Finish`

Once the plugin is installed, it should just work since the
`.checkstyle` file is generated for each project via the `eclipse` buildr
task.

Errors will appear in your editor and in the problems console window.

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

Also note that Eclipse may complain when it doesn't recognize the module name
as being a valid argument to the @SuppressWarnings annotation.  You can turn
off this warning by going to Java -> Compiler -> Errors/Warnings in the
Eclipse Preferences window.  Go to the Annotations section and set "Unhandled
token in '@SuppressWarnings'" to "Ignore".

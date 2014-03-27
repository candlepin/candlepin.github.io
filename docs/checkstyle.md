---
layout: default
categories: developers
title: Checkstyle
---
{% include toc.md %}

Candlepin uses [Checkstyle](http://checkstyle.sourceforge.net/) to ensure the
code remains as readable as possible. You can run checkstyle from both the
command line and from within [Eclipse](http://www.eclipse.org/).

## Command line
Simply run the following command, `buildr candlepin:checkstyle` will result in
the report file located in `reports/checkstyle_report.xml`.

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

Once the plugin is installed, it should just work (TM) since we checked in the
`proxy/.checkstyle` configuration file.
Errors will appear in your editor and in the problems console window.

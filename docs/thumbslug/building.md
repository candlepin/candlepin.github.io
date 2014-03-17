---
layout: default
categories: thumbslug
title: Getting Started
---
{% include toc.md %}

# Getting started

You can browse the source code at <http://git.fedorahosted.org/git/thumbslug.git/>.

For anonymous access to the Thumbslug source code, feel free to clone the repository:

```console
$ git clone git://github.com/candlepin/thumbslug.git
```

Thumbslug committers can clone the repository using the ssh url, which is
required if you want to push changes into the repo (and of course you need
permission to do so).

```console
$ git clone git@github.com:candlepin/thumbslug.git
```

for more information on working with Git, checkout the
[Spacewalk](https://fedorahosted.org/spacewalk/)
[GitGuide](https://fedorahosted.org/spacewalk/wiki/GitGuide).

## Building

### Prerequisites

Candlepin uses [buildr](http://buildr.apache.org) as its build tool (primarily
because we don't like maven).  For building on Fedora 17, you will need: java,
tomcat6, gettext, and buildr.

* `$ sudo yum install ruby rubygems ruby-devel gcc perl-Locale-Msgfmt java-1.7.0-openjdk-devel`
* `$ sudo gem update --system`
* `$ sudo -s`
* `# export JAVA_HOME=/usr/lib/jvm/java-1.7.0/`

   You may want 1.6.0 depending on OS version
   {:.alert-caution}
* `# gem install bundler`
* Return to your normal user account and candlepin.git checkout.
* `$ bundle install`

For other options, check the buildr site: <http://buildr.apache.org/installing.html>

---
categories: developers
title: Developer Notes
---
{% include toc.md %}

This page contains a variety of information for those intending to work on Candlepin and it's associated sub-projects.

# Code Style
For Java code, we have checkstyle set up. You can configure it in Eclipse to
report violations as errors, or run from the CLI. See instructions
[here](checkstyle.html).

For Python, stick to the guidelines in PEP8:
<http://www.python.org/dev/peps/pep-0008/>. Also, run `make stylish` to run pep8,
pyflakes, pyqver, rpmlint, and a few subman specific code checks.

For C, run this on your code before you commit: `indent -linux -pcs -psl -ci8
-cs -cli8 -cp0 yourawesomefile.c`. Note that you may need to double-check that
the "\*" is on the right line, and feed in arguments to indent as appropriate.

# Committing Code Changes

## Commit Messages
General commit messages should follow the following format:

```text
A short one line description of what you did.

Then a newline, and optionally provide any extra information here.
```

When committing a bug fix from bugzilla (BZ), the following format should be used:

```text
\<Bug Number\>: Short one line description of what was done.

Then optionally a newline and other information.
```

For example:

```text
712415: Make the names consistent between list --installed and list --consumed
```

We use these for changelog's when tagging builds. It may seem pedantic but when
you need to process a few hundred lines it's very helpful if they're typo free,
changelog friendly, and have the bz's automatically detected.

A general git guide can be found [here](https://fedorahosted.org/spacewalk/wiki/GitGuide).

## Important Notes
 * Please be sure that when committing code, you have your git author info set up correctly, and that you are working as the correct user.
 * Take a few seconds before committing to ensure that your commit messages follow the correct format, and are typos free.

# Testing
Testing is extremely important for the team. We have a variety of test suites
on the go, all of which should be kept passing before you commit to any given
codebase.

1. Candlepin
   * Java unit tests: Standard junit tests which can be run from within Eclipse or from the CLI.
 
     ```console
     $ buildr test
     ```
   * Functional rspec tests:
 
     ```console
     $ buildr spec
     ```
   * The safest bet is to run everything before committing:
 
     ```console
     $ buildr check_all
     ```

1. Subscription Manager
   * Python nosetests: Generally unit tests, which should *not* require root access or a live Candlepin server to run.
 
     ```console
     $ nosetests
     ```
 
     Subscription-manager tests need an X server DISPLAY set, since they run gui tests as well. To avoid showing those tests on screen, you can setup an offscreen vncserver and set DISPLAY to point to that server for the tests.
 
     ```console
     $ DISPLAY=:13 nosetests
     ```
1. python-rhsm
   * Still a very small suite of tests which needs work, and requires a live Candlepin server on localhost. (needs work)
 
     ```console
     $ ./setup.py nosetests
     ```
 
     The setup.py is required just the first run to compile the C library and
     copy it to the correct location for the unit tests. After that you can use
     nosetests normally, although you may need to re-run the above if anything
     changes in the C code.
1. Headpin

   ```console
   $ rake spec
   ```

1. Thumbslug: TODO

## Mocks
When possible, we try to leverage mocks in unit tests to skip
complicated/costly setup of objects we're not interested in, and instead just
focus on testing the component we are interested in. This is a bit of an art
form in itself and can be quite tricky to get the hang of, and when it goes
wrong you can end up with an un-maintainable mess. Look for good examples,
experiment, chat with the team, and in general just try to leverage this when
possible. We're all still learning how this works. :)

In the Java unit tests this is accomplished with mockito: <http://mockito.org/>

In subscription-manager and python-rhsm we use the python-mock module: <http://www.voidspace.org.uk/python/mock/>

In headpin we use mock capabilities of rspec 2.0: <http://relishapp.com/rspec/rspec-mocks>

# Architecture Gotcha's
Candlepin can be a confusing beast. Some pointers that may help to understand how things work and why they are the way they are.

## Service Adapters
Central to Candlepin's design is the use of adapters to abstract services which
may or may not be provided by Candlepin components. Objects such as
Subscriptions, Products, and Users all may live in external systems depending
on the deployment.

Tips:
 * Don't directly query the curators for these objects, use the service adapters instead.
 * Don't relate hiberante objects we *do* store in our database directly to these objects. You'll have to store the ID instead.

## Subscriptions vs Pools
These two objects are almost the exact same thing. They both exist because we
may not be the canonical source for Subscription data. As such we use the
Subscription service adapter to query subscription data, and use this to
create/update/delete our own Pool objects (which are always in our database).
The Pool's are then used to track consumption.

## Reading SSL Data for Debugging
See [the debugging with wireshark page](debugging_with_wireshark.html)

# Bugs
 * When marking a bugzilla as modified, include a comment with:
   * SHA1 for the commit(s) of the branches your fix went to, be sure to do
     this *after* you push, any rebase will change the SHA1.
   * the version of the package the fix will appear in. (look for the most recent tag, and add 1)

# Tips

## Auto-Generating `candlepin.conf`
Buildr can auto-generate candlepin.conf for you.  This is very useful when you
are constantly switching between databases.  See [the AutoConf page](auto_conf.html).

## Running subscription-manager from a source checkout
To avoid having to "make install" or "make install-files" (install all the code
but not the default configs, etc) or installing with tito, you need to make
sure bin/subscription-manager can find the code from the source checkout on
it's PYTHONPATH.

What complicates simpling setting PYTHONPATH is that installed eggs are
prepended to the system path before PYTHONPATH. So if a subscription-manager
egg is installed, this doesnt work.

One approach to work around this is to use the fact that the local directory is
first in the path, so we can make relative imports find the local
subscription-manager by symlinking bin/subscription_manager to
src/subscription_manager.

```bash
# project root
cd subscription-manager

# go into bin/ subdir
cd bin

# symlink bin/subscription-manager to ../src/subscription_manager
ln -s ../src/subscription_manager subscription_manager
```

With that setup, running `sudo bin/subscription-manager` from the project root
will use the code from the local checkout.

Note that this is only for the application code. plugins will not be found this
way, since the code specifically looks for them installed on the system.

## Backup / Restore A Database
It can be helpful for developers to save a postgresql database for later use
particularly when they're loaded with a complex or large amount of data.

```console
$ pg_dump -U candlepin candlepin > candlepindb.sql
```

To restore an old database:

```console
$ sudo service tomcat6 stop
$ dropdb -U candlepin candlepin && createdb -U candlepin candlepin
$ psql -U candlepin candlepin < ~/src/candlepin/candlepindb.sql
$ buildconf/scripts/deploy -g -t
```

## Debugging subscription-manager with eclipse/pydev
Normally, eclipse is kind of useless for debugging subscription-manager
since it runs as root, and eclipse does not support that.

However, it is possible to remote debug a root owned process with
eclipse.

The setup needs:
 * eclipse
 * pydev
 * python remote debug server setup in eclipse/pydev
   (see [pydev remote debugger setup](http://pydev.org/manual_adv_remote_debugger.html) and
    [How To Debug Python Scripts With Eclipse](http://wiki.xbmc.org/index.php?title=How-to:Debug_Python_Scripts_with_Eclipse)

With the remote debug setup, subscription-manager can connect to the eclipse debugger server, even if
the process is root owner (or, indeed, remote).

So next step is to alter the code to connect to the eclipse/pydev debugger. Somewhere early in the
startup process (I usually use the 'subscription-manager' or 'subscription-manager-gui' scripts)
add the following lines, adjusting paths for your eclipse/pydev setup

```python
sys.path.append('/path/to/your/eclipse/installation/eclipse/plugins/org.python.pydev_2.7.1.2012100913/pysrc')
import pydevd
pydevd.settrace()
```

It can be useful to make a copy of the scripts as 'subscription-manager-debug' that include the debug setup code.

With this setup, 'sudo subscription-manager-debug' will start the subscription-manager process as root, and
try to attach to the pydev remote server. If a server is not running, expect an exception telling you that.

## Debugging yum, yum plugins, subscription-manager plugins
Adding the `pydevd.settrace()` line to /usr/bin/yum will work as expected. However, since it will be using
the installed subscription-manager code, locally set breakpoints will not be found. The plugins look
for subscription-manager code directly in /usr/share/rhsm.

This assumes 'yum-debug' is a copy of /usr/bin/yum with the debugger startup code added.

One simple workaround is to point /usr/share/rhsm to /home/you/path/to/checkout/of/subscription-manager/src
via a symlink. This isn't suggested for a 'production' setup, but it's quick and simple for debugging.

```bash
# move installed rhsm modules away
sudo mv /usr/share/rhsm /usr/share/rhsm-real

# create a /usr/share/rhsm-debug that points to your checkout
sudo ln -s /home/you/path/to/checkout/of/subscription-manager/src /usr/share/rhsm-debug

# points /usr/share/rhsm to /usr/share/rhsm-debug
sudo ln -s /usr/share/rhsm-debug /usr/share/rhsm
```

With that setup, 'sudo yum-debug' will start yum, connect to the pydev debugger, and use
the code from local checkout for the rhsm modules the yum plugins import.

subscription-manager plugins (/usr/share/rhsm-plugins) will all find the correct
local copy of code with this setup.

Note similar setups can be done with [winpdb](http://winpdb.org/). There are
other ways to set source paths, but this is pretty quick and easy.

---
title: Running Tests
---
{% include toc.md %}

## Setup

```console
$ yum install python-pip rhnlib
$ sudo pip install -r test-requirements.txt
```

## Running Tests

Jump in to your subscription-manager check-out and run `nosetest`.  The tests will run.  However, if you are in an SSH session, then some of the GTK tests will fail.  Make sure that you have the DISPLAY environment variable set: `export DISPLAY=:0.0`.  Or you can use [Xvfb](http://en.wikipedia.org/wiki/Xvfb) and never have to worry about the problem again.  See the nose-xvfb section below.

### Running Specific Tests

Nose is really great at letting you zero in on just what you want to run.

  * Want to run just one module?  Just provide the path to that module.  You can also use the Python dotted notation (test.my_test), but using the path lets you use tab completion in your shell

    ```console
    $ nosetests test/my_test.py
    ```
  * How about a single class?

    ```console
    $ nosetests test/my_test.py:TestClass
    ```
  * And now let's get really specific and run just one test

    ```console
    $ nosetests test/my_test.py:TestClass.test_method
    ```

It can be helpful to configure nose to assign [numeric
IDs](https://nose.readthedocs.org/en/latest/plugins/testid.html) to each test
making it easier to run specific tests.

In your global `~/.gitignore` add

```
.noseids
```

When you run Nose, to create the ids, run with `--with-id`.  Print all the IDs
with the `-v` option.  Then use the numbers for additional runs.

```console
$ nosetests --with-id -v tests/my_test.py
#1 test_blah (test.my_test.TestClass) ... ok
#2 test_blah2 (test.my_test.TestClass) ... ok
$ nosetests 1 2
```

Be aware, however, that the `--with-id` option causes issues when Nose is run in
verbose mode and you are using YANC to print the output in color.  There is an
[unmerged PR](https://github.com/nose-devs/nose/pull/691) around the issue but
Nose is no longer actively maintained.

IDs also allow Nose to run the tests that failed during the previous run

```console
$ nosetests --failed
```

You can configure Nose to use certain options by default via a `~/.noserc` file.
See [the docs](http://nose.readthedocs.io/en/latest/usage.html#configuration)
for more information.

## Plugins

Nose has a lot of plugins.  Some are [built-in](https://nose.readthedocs.org/en/latest/plugins/builtin.html) and others are [third-party](http://nose-plugins.jottit.com/).  Some of these plugins are configured to run by default via the settings in `setup.cfg`

### [nose-randomly](https://pypi.python.org/pypi/nose-randomly) (Third-party)

Ordinarily, Nose will run all the tests in the same order every time.  This can
cause problems where a test pollutes the test environment (e.g. via
monkey-patching) and other tests are written that unwittingly rely on this
pollution.  To combat this issue, we use nose-randomly which randomly orders
both the test modules and the test methods within a module.  Nose-randomly is
configured in `setup.cfg` to run automatically, so you don't need to do anything
to use it.

When you run the tests, Nose-randomly will output the RNG seed it is
using.  By default it uses the epoch.

```console
$ nosetests
Using --randomly-seed=1468345257
....
```

If you have a failure, you can use the `--randomly-seed` option to specify the
same seed so you get the same order.  Note that the seed will keep the same
order within any subset you stipulate.  E.g. `nosetests --randomly-seed=10` and
`nosetests --randomly-seed=10 test/test_certificate.py` will both provide the
same order when running the tests in `test_certificate.py`.  This property is
very useful when you've narrowed down the issue to one particular module.

When you submit a PR, our Jenkins instance will run the tests in random order.
To ensure that the same random order is used for the life of the PR, the Jenkins
sets the seed to the PR number.  You can see this in the Jenkins output. If you
are seeing Jenkins failures that don't appear when you run in another order, you
can reproduce them by setting the seed to your PR number.

### nose-xvfb (Third-party)

This plugin is essential for us in my opinion.  It lets you run all the tests with out using your own X server, so you don't get a bunch of dialogs popping up or failures because you don't have DISPLAY set.  Unfortunately, the plugin isn't in PyPI and has some dependencies so you have to do a little more of work.  The xorg-x11-server-Xvfb is available with no problem in Fedora.  In RHEL 6, things are a little weird because the package was moved to a new channel: RHEL Server Optional.  You can grab the package from there.

```console
$ yum install xorg-x11-server-Xvfb
$ nosetests --with-xvfb
```

And since this option is so useful, I put it in my `.noserc` like so:

```properties
[nosetests]
with-xvfb=True
```

### Capture
By default, Nose captures all the output to stdout.  If your test fails, then it will show the output, otherwise it goes in the trash.  We also use a plugin that captures all stderr too since the tests are very noisy otherwise.  If you want to see the output anyway, use `-s`.

ProTip: If you are invoking the Python debugger in code (`import pdb;
pdb.set_trace()`), you need to run with `-s`.  Otherwise, Nose will intercept
all of PDB's output and the tests will just appear to be hanging even though PDB
has started and is waiting for input.

### YANC (Third-party)
We can add a little color to our tests with the YANC plugin which is installed
with

```console
$ sudo pip install -r dev-requirements.txt
```

Now you can use the --with-yanc option to get color results for your test.  I find this so useful, that I just set it as `with-yanc=True` in `.noserc`.  Keep in mind that YANC and `--with-id -v` are mutually exclusive

### [nose-progressive](https://pypi.python.org/pypi/nose-progressive/) (Third-party)

Normally Nose prints out a period for each successful test and an E or and F for errors and failures.  That's pretty nice, but if you're short on space, you can use nose-progressive which consolidates all the output into a progress bar.  Error information is printed prettily and printed in such a way that you can open your editor right to the line you need (Make sure you have $EDITOR set to what you want).  This plugin works in tmux too.

```console
$ sudo pip install nose-progressive
$ nosetests --with-progressive
```

### Pdb

This plugin drops into pdb whenever there is a test with errors or failures.
Just use `--pdb` and `--pdb-failures`.

---
title: Make's 'stylish' Target
---
{% include toc.md %}

# make stylish

"stylish" is a target in the python code base Makefiles. It runs a series of
lints and style checkers.

Run it or Jenkins will hate you.

## pyqver
[pyqver](https://github.com/alikins/pyqver) is a tool that checks python code
to determine what version of python it needs to run.
It can tell you what is not backwards compatible to a given python version

We use it in it's "lint" mode so that it annotates source code lines that are not compatable
with python 2.4, the version of python from RHEL5. 

You should install this. 

If you see "pyqver.py: command not found", you need to install this. 

To install, clone the repo above:

```console
$ git clone https://github.com/alikins/pyqver.git
```

Then copy pyqver2.py somewhere in your $PATH.

"make versionlint" will run it specifically. 
It is part of "make stylish"

## pep8
[pep8](https://github.com/jcrocholl/pep8) is the general style guide for python code. See the
specification [here](http://www.python.org/dev/peps/pep-0008/).

We generally try to adhere to it.

'pep8' the tool, is a lint-like tool that will tell you when and how your code is
not pep8 compliant

Fedora and EPEL have 'python-pep8' available. Newer versions are available from PyPi or
from the guthub repo above.

"make pep8" will run it specifically.
It is part of "make stylish"

## pyflakes
[pyflakes](https://pypi.python.org/pypi/pyflakes) is another static analysis
tool for python.

"make pyflakes" runs it spefically.
It is part of "make stylish"

## tablint/trailinglint
This target checks python code for trailing whitespace or the use of tabs.

They are part of "make stylish"

## debuglint
This target checks python code for debugger invocations ('import pdf; pdb.set_trace()', etc).

It is part of "make stylish"

## find-missing-symbols
This target tries to verify that any gtk signals that are defined in .glade files are at
least references from python code.

It is part of "make stylish"

## find-missing-widgets
This target tries to find any references to gtk widget names as strings, and verify that
they are defined.

It is part of "make stylish"

## rpmlint
rpmlint checks the specfile for common errors and mistakes. 

It is part of "make stylish"

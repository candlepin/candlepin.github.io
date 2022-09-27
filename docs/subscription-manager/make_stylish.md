---
title: make stylish
---
{% include toc.md %}

# make stylish

## Formatting

First things first: we are using [black](https://github.com/psf/black) to format the code.
Install it (either from package manager or via pip) and run it before you make a commit.
CI is configured to check if the code is formatted correctly and will fail if the formatting differs.

## Linters

`make stylish` invokes several programs.

- `rpmlint` checks if our `.spec` file is formatted correctly.
- `flake8` checks all Python files for formatting issues. `black` solves many of them, so you will get list of undefined variables, imported-yet-unused packages or list of lines that are too long.

## pre-commit hook

You can write small bash script that will be invoked every time you make a commit or before you make a push.

Place a file to `.git/hooks/pre-commit` or `.git/hooks/pre-push`:

```bash
#!/usr/bin/bash

black .
flake8
```

Please note that this will not work for branches that were not formatted with `black`, e.g. all of RHEL 8 and RHEL 9.0 as well (up until subscription-manager-1.29.28).

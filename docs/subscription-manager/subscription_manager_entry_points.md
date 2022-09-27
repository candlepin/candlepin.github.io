---
title: Entry Points
---
{% include toc.md %}

# What, When and Where of subscription-manager

Many different apps can load and run subscription-manager code, and they are
not particularly consistent in how they do it.

Some parts of subscription-manager code only need to happen once per process
(log and config setup, for example). Other aspects can happen more often, but should
be kept to a minimum (loading client side certificates, reading/write caches, etc.).

## `/usr/sbin/subscription-manager`

1. sets up i18n (`i18n.configure_i18n()`)
1. sets up logging (`logutil.init_logger()`)
1. sets up dep injection (`injectioninit.init_dep_injection()`)
1. `import managercli`
1. runs `managercli.ManagerCLI().main()`

`ManagerCLI()` creates an instance of each of the `managercli.*Command` classes.

The `ManagerCLI().main()` runs the `Command.main()` of the command. The `main()`
parses all the args, sets up connections to Candlepin (UEP, etc.) if needed, and
runs the `Command._do_command()`

All the `CliCommand()` subclasses are `init()`'ed, but only one will have its `.main()`
and its `_do_command()` triggered. 

---
title: Design overview
---

# Design overview

subscription-manager is a CLI tool, a DBus server, and a DNF plugin.

Command line interface can be used manually (by system administrators) or programmatically (via Ansible).

DBus server is used by other programs: [Cockpit](https://cockpit-project.org/), [Anaconda installer](https://anaconda-installer.readthedocs.io/en/latest/) and some other projects.

The DNF plugin is triggered every time DNF is invoked (unless disabled either in configuration file or via CLI option).

---
title: Plugins
---
# Plugins
Currently we have various ExternalModules that enable customization of
Candlepin's behavior.  The primary downside to this approach is that any jar
that provides these classes must actually be laid down over the exploded war,
which makes installation difficult.  Below, a plugin scheme is outlined to
alleviate this.

* Establish a known directory to put all plugin jars.
* The plugin container scans jars in this folder, pulling in all contained
  classes.
* It then looks for a commonly named Guice plugin class and overrides the
  candlepin modules with the plugin-provided module

This would allow for complete separation of the base candlepin codebase from
any extension points.  This would also allow for default provided
implementations to be cherry picked for customization.

# Open Questions
* How do we handle multiple implementations that bind to the same interface?
* Should we allow hooks for the plugin to set up any db tables it needs?
* Should we only allow ServiceAdapter implementations, or permit plugins to
  define resources as well?  (This would raise a host of follow-up questions)

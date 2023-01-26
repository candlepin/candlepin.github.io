---
title: D-Bus Development Notes and Tips
---
{% include toc.md %}

# Bus Configuration

By default, the D-Bus system bus is locked down tightly.  Each service is
expected to provide its own bus configuration that tells D-Bus what is and is not
allowed.  Our configurations are stored in `etc-conf/com.redhat.RHSM1.conf` and
`etc-conf/com.redhat.RHSM1.Facts.conf`.  **If you add a new interface, you must
edit the appropriate file to expose it**.

For example, let's suppose we add a new interface `com.redhat.RHSM1.Products`
that reports on a consumer's installed products.  We would need to edit
`etc-conf/com.redhat.RHSM1.conf` and add a stanza like

```xml
<allow send_destination="com.redhat.RHSM1"
    send_interface="com.redhat.RHSM1.Config"/>
```

under the default context policy element.

## Local development

You may want to develop subscription-manager without having its RPMs installed.

For D-Bus development, you have to copy the two mentioned `.conf` files to
`/etc/dbus-1/system.d/`. After adding or editing them, you have to tell D-Bus
to reload the configuration for the changes to take effect:

```console
$ sudo systemctl reload dbus
```

Then you can start the server by running

```console
$ sudo PYTHONPATH=src/ python3 -m subscription_manager.scripts.rhsm_service --verbose
```

# Smoke Testing

I find the easy way to test is with `d-feet` which is a graphically application
that allows you to browse D-Bus objects and the interfaces they make available.
Unfortunately `d-feet` is only available in Fedora.  So when testing on Red Hat
Enterprise Linux systems, my tool of choice is `dbus-send`.  The manual page for
`dbus-send` is fairly good, but in essence you tell `dbus-send` the bus to use,
the bus name to talk to and the bus method (*including the interface*) to call
and then any required arguments.  Here's how to call the `Config` object's
`GetAll` method for example.

```console
$ sudo dbus-send --system --print-reply --dest=com.redhat.RHSM1
'/com/redhat/RHSM1/Config' com.redhat.RHSM1.Config.GetAll
```

Note that `sudo` is required since I'm talking to the system bus.

# Ad Hoc Testing

The services can be brought up without installing them and all the requisite
configuration files by running the relevant executable in the `bin` directory.
For example, running `bin/rhsm-service` will bring up the `com.redhat.RHSM1`
object.  Pass in the `-h` flag for information on the options the script can
take.  You can define verbosity level, a different bus name, and specify which
bus (system or session) to use.

# Useful Tools

* busctl (from systemd package) - CLI tool for interacting with D-Bus
* gdbus (from glib2 package) - CLI tool for interacting with D-Bus
* dbus-send (from dbus package) - CLI tool for interacting with D-Bus
* dbus-monitor (from dbus package) - probe to print bus messages
* d-feet - graphical tool to interact with D-Bus

I find d-feet to be the easiest to use for just ad-hoc tests.  One of the CLI
tools is the better choice if you're going to be running the same command over
and over.

# Learning D-Bus

* [D-Bus Specification](https://dbus.freedesktop.org/doc/dbus-specification.html) is
  start here.  It's quite readable and will explain the basic concepts to you.
* [D-Bus Tutorial](https://dbus.freedesktop.org/doc/dbus-tutorial.html) is also a
  good introduction to the basic concepts.
* [Designing a D-Bus API](https://dbus.freedesktop.org/doc/dbus-api-design.html) 
  is good outline of the best practices when designing a D-Bus API
* [dbus-python Tutorial](https://dbus.freedesktop.org/doc/dbus-python/doc/tutorial.html) is
  of limited use since it is terse and incomplete in sections.
* [dbus-python API](https://dbus.freedesktop.org/doc/dbus-python/api/) is API
  docs for dbus-python which is what we use for interacting with D-Bus in
  subscription-manager.
* [Writing polkit applications](https://www.freedesktop.org/software/polkit/docs/master/polkit-apps.html)
  will be useful when we decided to add polkit integration

# Examples

* `certmonger` has a D-Bus api that models X.509 certs (`org.fedorahosted.certmonger.ca interface`)
* `dnfdaemon` has an interface to packages/repos (`org.baseurl.DNfSession`)
* `telepathy` has and extensive D-Bus API and python bindings
  (`org.freedesktop.Telepath`)
* `seahorse` is a keyring tool with D-Bus interfaces (`org.gnome.seahorse`)
* `kwallet` has a large D-Bus API (`org.kde.kwallet5`)
* `org.freedesktop.Udisks2` is a good example of using the
  `org.freedesktop.DBus.ObjectManager` interface
* `org.fedoraproject.FirewallD1` is another large API

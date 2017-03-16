---
title: Tips for DBus Development
---
{% include toc.md %}

# Bus Configuration

By default, the DBus system bus is locked down tightly.  Each service is
expected to provide its own bus configuration that tells DBus what is and is not
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

# Smoke Testing

I find the easy way to test is with `d-feet` which is a graphically application
that allows you to browse DBus objects and the interfaces they make available.
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


---
title: Installation
---
{% include toc.md %}

# Installation

In order to install subscription-manager please do the following:

1. Enable the subscription-manager copr repo for your release:

   Fedora 22:

   ```console
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/fedora-22/dgoodwin-subscription-manager-fedora-22.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-fedora-22.repo
   ```

   Fedora 23:

   ```console
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/fedora-23/dgoodwin-subscription-manager-fedora-23.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-fedora-23.repo
   ```
   EPEL for Centos 6:

   ```console
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/epel-6/dgoodwin-subscription-manager-epel-6.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-epel-6.repo
   ```
   EPEL for Centos 7:

   ```console
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/epel-7/dgoodwin-subscription-manager-epel-7.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-epel-7.repo
   ```

   This repo provides subscription-manager as well as python-rhsm packages.

1. Install subscription-manager

   ```console
   $ yum install subscription-manager
   ```
1. Optionally install the subscription-manager-gui

   ```console
   $ yum install subscription-manager-gui
   ```


# Upstream Subscription Manager information
The subscription-manager code base is [here](http://github.com/candlepin/subscription-manager).

The project is built for the latest versions of Fedorai (and submitted to Fedora
Updates), EPEL for Centos 6 and EPEL for Centos 7
[here](https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/).

# Installation of Upstream from Source Code

The process below is for Fedora 24 and RHEL/CentOS 6/7. Other distributions may
require some adaptation to the steps below.

1. You need to install following RPM packages to build binaries of
   subscription-manager:

   Fedora 24

   ```console
   $ dnf install git gcc make glib2-devel dbus-glib-devel libnotify-devel GConf gtk3-devel intltool python-devel openssl-devel redhat-rpm-config m2crypto librsvg subscription-manager subscription-manager-gui
   ```

   RHEL/CentOS 7

   ```console
   $ yum install git gcc make glib2-devel dbus-glib-devel libnotify-devel GConf2 GConf2-devel gtk3-devel intltool python-devel openssl-devel subscription-manager subscription-manager-gui
   ```

   > Note: when you are trying to compile subscription-manager on RHEL7, then package `GConf2-devel` is not available in "default" repository `rhel-7-server-rpms`. You have to enable another optional repository:

   ```console
   $ subscription-manager repos --enable=rhel-7-server-optional-rpms

   ```

   When this optional repository is enabled on RHEL7, then you can install `GConf2-devel`:

   ```console
   $ yum install GConf2-devel
   ```

   RHEL/CentOS 6

   ```console
   $ yum install git gcc make glib-devel dbus-glib-devel libnotify-devel GConf2-devel gtk2-devel intltool python-devel openssl-devel subscription-manager subscription-manager-gui
   ```

   Note: The packages `subscription-manager` and `subscription-manager-gui` are
   in the list for convenience to pull in requisite dependencies.

1. Get the source code of subscription-manager from GitHub:

   ```console
   $ git clone git://github.com/candlepin/subscription-manager.git
   ```

1. Go to the source directory of python-rhsm and build the custom C extensions

   ```console
   $ python ./setup.py build_ext --inplace
   ```

   If you want to install python-rhsm (Fedora or CentOS) onto the system:

   ```console
   $ sudo python ./setup install
   ```

   Note: Installing the upstream version on a CentOS/RHEL system is not
   recommended as it will overwrite the existing installation of python-rhsm.

1. Build and install subscription-manager itself:

   ```console
   $ cd subscription-manager
   $ make
   ```

   Again, you probably don't want to overwrite your installation of
   subscription-manager at RHEL 6/7. Execute upstream subscription-manager
   as follows:

   ```console
   $ export PYTHONPATH=./src/:./python-rhsm/src/
   $ # Pick one of the lines below:
   $ export SUBMAN_GTK_VERSION=3   # Fedora and RHEL7
   $ export SUBMAN_GTK_VERSION=2   # RHEL 6
   ```

   To test your local installation of subscription-manager type:

   ```console
   $ sudo ./bin/subscription-manager version
   $ sudo ./bin/subscription-manager-gui
   ```

   If you want to install subscription-manager to the system (Fedora or
   CentOS):

   ```console
   $ sudo make install
   ```

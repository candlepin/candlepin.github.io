---
title: Installation
---
{% include toc.md %}

# Installation

In order to install subscription-manager please do the following:

1. Enable the subscription-manager copr repo for your release:

   Fedora 22:

   ```bash
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/fedora-22/dgoodwin-subscription-manager-fedora-22.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-fedora-22.repo
   ```

   Fedora 23:

   ```bash
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/fedora-23/dgoodwin-subscription-manager-fedora-23.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-fedora-23.repo
   ```
   Epel for Centos 6:

   ```bash
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/epel-6/dgoodwin-subscription-manager-epel-6.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-epel-6.repo
   ```
   Epel for Centos 7:

   ```bash
   $ wget https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/repo/epel-7/dgoodwin-subscription-manager-epel-7.repo -O /etc/yum.repos.d/dgoodwin-subscription-manager-epel-7.repo
   ```

   This repo provides subscription-manager as well as python-rhsm packages.

1. Install subscription-manager

   ```bash
   $ yum install subscription-manager
   ```
1. Optionally install the subscription-manager-gui

   ```bash
   $ yum install subscription-manager-gui
   ```


# Upstream Subscription Manager information
The subscription-manager code base is [here](http://github.com/candlepin/subscription-manager).

The project is built for Fedora 22, Fedora 23, Epel for Centos 6 and Epel for Centos 7 [here](https://copr.fedoraproject.org/coprs/dgoodwin/subscription-manager/).

# Installation of Upstream from Source Code

Installation process is described for Fedora 24 and RHEL/CentOS 6/7. It maybe be possible to install on other distributions by adapting the steps as necessary.

1. First of all you will need to install following RPM packages required to build binaries of subscription-manager:

   Fedora 24

   ```bash
   $ dnf install git gcc make glib2-devel dbus-glib-devel libnotify-devel GConf gtk3-devel intltool python-devel openssl-devel redhat-rpm-config m2crypto librsvg subscription-manager subscription-manager-gui
   ```

   RHEL/CentOS 7

   ```bash
   $ yum install git gcc make glib2-devel dbus-glib-devel libnotify-devel GConf2 gtk3-devel intltool python-devel openssl-devel subscription-manager subscription-manager-gui
   ```

   RHEL/CentOS 6

   ```bash
   $ yum install git gcc make glib-devel dbus-glib-devel libnotify-devel GConf2-devel gtk2-devel intltool python-devel openssl-devel subscription-manager subscription-manager-gui
   ```

   Note: packages `subscription-manager` `subscription-manager-gui` are installed at Fedora and CentOS to reduce list of required packages.

1. Get source code of subscription-manager from GitHub:

   ```bash
   $ git clone git@github.com:candlepin/subscription-manager.git
   ```

1. Go to the source directory of python-rhsm and build this python module (it is part of subscription-manager source code)

   ```bash
   $ cd subscription-manager/python-rhsm
   $ python ./setup.py build
   ```

   When you use RHEL 6/7 then you probably don't want to override system installation of python-rhsm package and break you installation. In this case you can install python-rhsm locally:

   ```bash
   $ python ./setup.py build_ext --inplace
   ```

   In case you want to install python-rhsm (Fedora or CentOS) to system type:

   ```bash
   $ sudo python ./setup install
   ```

1. Build and install subscription-manager itself:

   ```bash
   $ cd subscription-manager
   $ make
   ```

   Again, you probably don't want to overwrite your installation of subscription-manager at RHEL 6/7. To execute upstream subscription-manager type following commands:

   ```bash
   $ export PYTHONPATH=./src/:./python-rhsm/src/
   $ export SUBMAN_GTK_VERSION=3   # Fedora and RHEL7
   $ export SUBMAN_GTK_VERSION=2   # RHEL 6
   ```

   To test your local installation of subscription-manager type:

   ```bash
   $ sudo ./bin/subscription-manager version
   $ sudo ./bin/subscription-manager-gui
   ```

   In case you want to install subscription-manager to system (Fedora or CentOS):

   ```bash
   $ sudo make install
   ```

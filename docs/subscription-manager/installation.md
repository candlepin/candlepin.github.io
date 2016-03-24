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

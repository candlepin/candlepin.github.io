---
categories: Developers
title: Developer Deployment
---

{% include toc.md %}

# Gutterball Developer Deployment

Instructions for deploying gutterball from source.

## Prerequisites

 * A functional Candlepin install [SOURCE](/docs/candlepin/developer_deployment.html) [RPM](/docs/candlepin/setup.html)
 * Configured and setup a local [Qpid server](/docs/candlepin/amqp.html)
 * [PostgreSQL](/docs/candlepin/setup.html#postgresql) installed as per candlepin.

## Instructions

All commands below are assumed relative to your candlepin project checkout: **$CHECKOUT_DIR**

1. **Get The Code**

   You should already have the code from your candlepin setup, but if not, you can get it as follows.

   ```console
   $ git clone https://github.com/candlepin/candlepin.git
   ```

1. **Setup QPid**

   ```console
   $ sudo yum install qpid-cpp-server-store qpid-cpp-server qpid-tools
   $ cd $CHECKOUT_DIR/gutterball/bin/qpid
   $ ./configure-qpid.sh
   ```

   **NOTE**: For instructions on how to completely wipe out all qpid configuration and start new, [READ](https://github.com/candlepin/candlepin/blob/master/gutterball/bin/qpid/README.md)

1. **Create a DB user for gutterball**

   ```console
   $ sudo su - postgres -c 'createuser -dls gutterrball'
   ```

1. **Run the deploy script**

   ```console
   $ cd $CHECKOUT_DIR/gutterball/
   $ bin/deploy -g
   ```

## Configuration

By default, gutterball's configuration is set up for a from source developer deployment, so you may not need an actual
/etc/gutterball/gutterball.conf. If so however, the properties you can use and their defaults can be viewed in
[this file](https://github.com/candlepin/candlepin/blob/master/gutterball/src/main/java/org/candlepin/gutterball/config/ConfigProperties.java).





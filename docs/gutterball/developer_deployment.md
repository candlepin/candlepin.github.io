---
categories: Developers
title: Developer Deployment
---

{% include toc.md %}

# Gutterball Developer Deployment

Instructions for deploying gutterball from source.

## Prerequisites

 * A functional Candlepin install
 * Configured and setup a local [Qpid server](/docs/candlepin/amqp.html)

## Instructions

 * Setup [MongoDB](mongodbsetup.html)
   * WARNING: Gutterball is currently transitioning to postgresql, these instructions will change.
 * Run deploy script:

   ```
   $ cd gutterball/
   $ bin/deploy
   ```

## Configuration

By default, gutterball's configuration is set up for a from source developer deployment, so you may not need an actual /etc/gutterball/gutterball.conf. If so however, the properties you can use and their defaults can be viewed in [this file](https://github.com/candlepin/candlepin/blob/master/gutterball/src/main/java/org/candlepin/gutterball/config/ConfigProperties.java).





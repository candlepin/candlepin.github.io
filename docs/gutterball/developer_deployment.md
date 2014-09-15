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

 * cd gutterball/
 * Setup [MongoDB](mongodbsetup.html)
   * WARNING: Gutterball is currently transitioning to postgresql, these instructions will change.
 * Run deploy script:
   ```
   bin/deploy
   ```





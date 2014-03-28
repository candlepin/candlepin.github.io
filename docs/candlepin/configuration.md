---
layout: default
categories: usage
title: Candlepin Configuration
---
{% include toc.md %}

Currently, candlepin configuration file (`/etc/candlepin/candlepin.conf`)
allows for the following types of configuration:

## JPA Configuration
All JPA configuration entries must use jpa.config prefix. JPA configuration
section can be used to override/define various hibernate properties that
usually go in the 'properties' section of `persistence-unit` section in
`persistence.xml` file. An example configuration:

```properties
   jpa.config.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
   jpa.config.hibernate.connection.driver_class=org.postgresql.Driver
   jpa.config.hibernate.connection.url=jdbc:postgresql:candlepin
   #jpa.config.hibernate.hbm2ddl.auto=create ** w/ this set restarting tomcat clears the db
   jpa.config.hibernate.hbm2ddl.auto=update
   jpa.config.hibernate.connection.username=candlepin
   jpa.config.hibernate.connection.password=
   jpa.config.hibernate.show_sql=false
```

## OAuth configuration
```properties
candlepin.auth.oauth.enable = true
candlepin.auth.oauth.consumer.rspec.secret = rspec-oauth-secret
```

## Module Configuration
All module configuration entries must use module.config prefix. The right-hand
side (value) of the module configuration entry defines the class name of a
sublclass of `com.google.inject.AbstractModule` that is used to define binding
for a given module. For examples of bindings for a module see
`org.candlepin.guice.CandlepinProductionConfiguration` class. Example of module
configuration as used in candlepin.conf:

```properties
module.config.example_module = org.candlepin.example.ExampleModule
```

## Logging
Any logging level can be set via the file. For example, to enable DEBUG for all
candlepin classes the following line should be used:

```properties
log4j.logger.org.candlepin=DEBUG
```

## Pretty Printed JSON
To have the JSON returned by Candlepin pretty printed, add the following line:

```properties
candlepin.pretty_print=true
```

## Manifest Export Web Application Prefix

To have manifest exports from this candlepin be traceable back by the receiving distributor system:

```properties
candlepin.export.webapp.prefix = system URL, e.g. 'localhost:8443/candlepin'
```

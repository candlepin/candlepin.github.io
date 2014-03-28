---
layout: default
categories: developers
title: Generating Test Certificates
---
Regenerating test certs with 1024 keys. Required due to changes in new Java security policies.
Steps to generate new certificates:

```console
$ openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ca.key -out ca.crt

$ openssl genrsa -out certchain.key 1024
$ openssl req -new -key certchain.key -out certchain.csr
$ openssl x509 -req -days 365 -in certchain.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out certchain.crt

$ openssl req -new -newkey rsa:1024 -nodes -out selfsigned.csr -keyout selfsigned.key
$ openssl x509 -trustout -signkey selfsigned.key -days 365 -req -in selfsigned.csr -out selfsigned.crt
```

When generating the ca.crt and certchain.crt be sure to use the same cert path
as defined in the test. Use openssh to view the contents of the cert
to see the different DNs.
{:.alert-caution}

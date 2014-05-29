---
categories: thumbslug
title: Thumbslug and Apache
---
Currently, yum clients connect directly to thumbslug, on the port thumbslug is
running on. Here  A user may want to place an apache instance between the
client and thumbslug, like so:

```text
yum  -(443)->  apache  -(8080)->  thumbslug
```

This works in terms of network plumbing, but does not in terms of ssl certs.
Thumbslug operates as a benevolent man-in-the-middle, unwrapping an ssl request
from yum, finding the relevant certificate from candlepin, and rewrapping the
request with an upstream certificate. If a user wanted to place an apache
instance infront of thumbslug, then apache would at minimum need to do the
unwrapping, and send the unencrypted request plus relevant metadata up to
thumbslug, which would then use the metadata to re-wrap the request with the
correct upstream cert.

One way to do this would be to alter the netty pipe in thumbslug to accept http
requests with cert data in the header, but that would involve splitting
thumbslug's functionality into being half in apache configs and half in java.
Another option would be to write an apache module to do all of what thumbslug
does, in order to avoid having the functionality of thumbslug split across two
very different services.

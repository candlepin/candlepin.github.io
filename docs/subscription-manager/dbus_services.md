---
categories: developers, design
title: D-Bus RHSM Services
---
{% include toc.md %}

# D-Bus Services Design

Included along with subscription-manager are a number of D-Bus services.
The following is a short description of each service/interface.
All services will be on the system bus.
All services names will begin with 'com.redhat.Subscriptions1'.
In the service name prefix above the '1' is the version of our API.

NOTE: Expect this document to change as new services are added and APIs updated.
Assume no backwards compatibility between one version of this API and the next,
until version 1 of the API is officially released/accepted in upstream.


## Services

- Address: com.redhat.Subscriptions1.Facts
  - Objects:
    - Path: /com/redhat/Subscriptions1/Facts/Host
      - Interface: com.redhat.Subscriptions1.Facts
      - Methods:
        - GetFacts () -> (Dict of {String, String))
            - This method returns the facts of the system
      - Properties:
        - Dict of {String, String} facts (read)
          - This property contains the last known facts
        - String last_update (read)
          - The last time the facts were updated
        - String name (read)

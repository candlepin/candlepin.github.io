---
categories: design
title: Compliance Snapshots
---
# Compliance Snapshots

To support reporting in general as well as usage based subscriptions, there is a need to create state and compliance snapshots of the Consumers in Candlepin. Ideally, this will occur in a way that keeps the acquisition, dissemination, and storage of the data as separate from the existing Candlepin tasks as possible. We already support asynchronous events, so this would be the best way to get this information to the tool that can process and store the data.

For every state change a consumer experiences [listed below] the JSON representation of the consumer will be included in the event. This JSON currently contains the certificates for the Consumer or any Entitlements. We should investigate whether we should create a new class of object mapper that defines which fields are needed in the JSON for the events. The EventFactory would need to be modified include the mapper, if needed. The event objects will need to be modified to include the rules version.

There will be 2 types of JSON blocks: Consumer, Entitlement

# State Changes Requiring Events

* Consumer creation [registration]
* Consumer update
* Consumer deletion [unregistration]
* Guest Consumer create
* Guest Consumer delete 
* Entitlement attachment
* Entitlement removal
* Entitlement regeneration
* Entitlement update [allowed for quantity only at current]
* Rules update



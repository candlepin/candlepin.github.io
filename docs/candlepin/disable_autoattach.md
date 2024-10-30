---
title: Disabling Auto Attach
---
{% include toc.md %}

# Disabling Auto Attach For An Owner
_This feature is available in both candlepin-0.9.54.11+ and candlepin-2.0.20+_

Candlepin allows disabling the Auto Attach functionality, on a per Owner basis, to accommodate entitlement stability
for Consumers of an Owner/Organisation during subscription renewals and/or other maintenance.

In many circumstances, Candlepin's Auto Attach functionality is not the greatest at selecting the most
appropriate entitlements to attach to a consumer. This is in part to the vast number of combinations
of entitlements that can be selected to cover the needs of a consumer and make it valid. Often times,
this can lead to a consumer being given entitlements that may not make sense for a customer's deployment,
leaving it up to and admin to manually fix them.

Providing the ability to disable Auto Attach at an owner level will stabilize consumer entitlement change
temporarily, while maintenance such as renewals, can be performed.

### Updating The Owner Setting
Auto Attach can be enabled/disabled for an Owner by modifying its Auto AttachDisabled field via the
update owner API.

```
PUT /owners/:owner_key
```

For example:

```bash
$ curl -X PUT -k -u username:password -d '{"Auto AttachDisabled":true}' -H "Content-Type: application/json" https://localhost:8443/candlepin/owners/your_owner_key
```

### Impact On Candlepin Features

#### Consumer Checkins
Auto Attach can be initiated by rhsmcertd when attempting to ‘heal’ the consumer. If Auto Attach is disabled
for the consumer's owner, it will be affected in the following ways:

- Only affected if healing is enabled in rhsmcertd and on the consumer itself.
- Wouldn't result in any extra entitlements as the healing request will be blocked due to the org level setting.
- End result would be a failed healing request that results in no new entitlements granted to the consumer.

> **NOTE:**
>
> The reason why no entitlements were found would only be visible in the rhsm.log
>
> Without a client update, we can not present a more informative message.

#### Direct Auto Attach From Subscription Manager
Auto Attach can be invoked from the CLI or the GUI. If Auto Attach is disabled
for the owner, it will be affected in the following ways:

**GUI**

- The Auto Attach process will fail, presenting an error to the user stating that Auto Attach has been disabled for the owner.

**CLI**

_subscription-manager register --auto-attach_

+ would result in a successful registration, but no entitlements due to the org level _disableAuto Attach_ setting.
+ client will report the standard “Unable to find available subscriptions for all your installed products.” message.
  - Without a client update, we can not present a more informative message.
+ The reason why no entitlements were found would only be visible in the rhsm.log

_subscription-manager attach --auto_

+ would result in no entitlements due to the org level setting.
+ The reason why no entitlements were found would only be visible in the rhsm.log

> **NOTE:**
>
> Without a client update, we can not present a more informative message.

#### Registering With Activation Keys
When registering with an activation key, auto attach can be invoked by setting the autoAttach property on the key(s).
If Auto Attach is disabled for the target owner, it will be affected in the following ways:

+ ALL keys specified on registration will fail, even if one of them had Auto Attach enabled.
+ If a failure occurred, the entire registration process is rolled back.
+ Appropriate message is displayed by the client.

#### Heal Entire Owner/Org
The _POST /owners/:owner_key/entitlements_ API call will attempt to heal all consumers in the targeted org.
If Auto Attach is disabled for the target owner, it will be affected in the following ways:

+ If the target owner has Auto Attach disabled, an error response with a meaningful message would be set in
  the job’s result data, and the job would fail.

#### Hypervisor Checkin
On hypervisor checkin, the host/guest mapping update will be skipped if Auto Attach is disabled on the owner
leaving candlepin in the state of the 'last checkin' until Auto Attach was again enabled.

+ Any potential migrations would occur the next time the virt-who checkin occurs.
+ Guests would heal themselves the next time rhsmcertd checks in.
+ Response will be a 400 - Bad Request in the case that Auto Attach is disabled for the target owner.



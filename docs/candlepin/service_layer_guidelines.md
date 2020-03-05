---
title: Service Layer Guidelines
---
{% include toc.md %}

# Service Layer Guidelines

The purpose of Service Layer is to decouple presentation (REST Resources) and business logic. For the purpose of implementing the Service Layer we compiled the following guidelines.

## Resources
* Any logic unrelated to the presentation layer should be extracted into a Controller or other classes hidden behind controller.
* Resource methods should not call other resource methods. They should call Controller instead in order to avoid dependencies on the presentation logic of the Resource methods.

## REST Exceptions
* Should reside in the package `resources.exceptions`.
* REST Exceptions represent HTTP Errors such as `BAD_REQUEST - BadRequestException`.

## Controllers
* Should reside in package `controller`. There are currently some classes in this package. These classes should be examined as some of them are domain services and not controllers.
* For arguments, where clean/feasible, single fields (e.g. String, Integer, etc.) should be preferred over ORM entities.
* Updating of subset of fields should still be possible (e.g. consumer POST). [Example](#update-subset-of-fields)

## Domain exceptions
* Should reside in the package `exceptions`.
* Exceptions throws from the Controllers such as `RulesValidationException`.
* All should be translated to the correct HTTP Responses via either `ExceptionMapper` or rethrows. If the spec tests are missing tests for some response codes, we should fill in gaps as we do the work.

## Examples

### Update subset of fields

```java
// Resource
@PUT
@Path("{activation_key_id}")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public ActivationKeyDTO updateActivationKey(
    @PathParam("activation_key_id")
    @Verify(ActivationKey.class)
    @NotEmpty String activationKeyId,
    @NotNull ActivationKeyDTO update) {
    log.debug("Updating activation key: {}", activationKeyId);
    ActivationKey ak = this.translator.translate(update, ActivationKey.class);
    ActivationKey updatedAk = this.activationKeyController
        .updateActivationKey(activationKeyId, ak);
    return this.translator.translate(updatedAk, ActivationKeyDTO.class);
}
```

Validate preconditions such as updated name matching a requested pattern. Do a partial update. I.E. Only update incoming non-null properties.

```java
// Controller
public ActivationKey updateActivationKey(String activationKeyId, ActivationKey update) {
    ActivationKey toUpdate = this.fetchActivationKey(activationKeyId);

    if (update.getName() != null) {
        Matcher keyMatcher = AK_CHAR_FILTER.matcher(update.getName());

        if (!keyMatcher.matches()) {
            throw new IllegalArgumentException(
                i18n.tr("The activation key name \"{0}\" must be alphanumeric or " +
                    "include the characters \"-\" or \"_\"", update.getName()));
        }

        toUpdate.setName(update.getName());
    }

    String serviceLevel = update.getServiceLevel();
    if (serviceLevel != null) {
        serviceLevelValidator.validate(toUpdate.getOwner().getId(), serviceLevel);
        toUpdate.setServiceLevel(serviceLevel);
    }

    if (update.getReleaseVer() != null) {
        toUpdate.setReleaseVer(update.getReleaseVer());
    }

    if (update.getDescription() != null) {
        toUpdate.setDescription(update.getDescription());
    }

    if (update.getUsage() != null) {
        toUpdate.setUsage(update.getUsage());
    }

    if (update.getRole() != null) {
        toUpdate.setRole(update.getRole());
    }

    if (update.getAddOns() != null) {
        toUpdate.setAddOns(new HashSet<>(update.getAddOns()));
    }

    if (update.isAutoAttach() != null) {
        toUpdate.setAutoAttach(update.isAutoAttach());
    }
    return activationKeyCurator.merge(toUpdate);
}
```

---
title: Candlepin DTOs
---
{% include toc.md %}

# Candlepin DTOs

In Candlepin 2.2, we've begun separating our model entities from actual DTOs (data transfer object) to be
returned by the various object mappers used throughout the code base. This gives us more flexibility in
changing the backend data model without impacting API, event or manifest consumers.



## When a DTO is Necessary

Use the following criteria as a guideline for when a DTO should be used:

1. If the object is returned by an API endpoint, then the object should be a DTO.
2. If the object embeds an object that should be a DTO, then the object should be a DTO.



## Using the DTOs

Applying and using the DTOs is pretty straight forward, as they don't contain any special logic or require
setup. Which DTOs should be used, however, is context-specific. If the DTO is planned to be sent to a
consumer, then the DTO from the appropriate package should be used. At the time of writing, there are four
main packages of DTOs, to cover various consumers:

- ```candlepin.dto.api```
  Contains DTOs for entities used as input and/or output through the Candlepin API (resources)

- ```candlepin.dto.rules```
  Contains DTOs for entities sent or received from the Javascript rules

- ```candlepin.dto.manifest```
  Contains DTOs for entities written to, or read from a manifest

- ```candlepin.dto.shim```
  Contains DTOs and tools used to translate between legacy and deprecated objects and the newer DTO framework

Once the proper DTO package has been selected, a DTO can be instantiated in one of two ways: either by
instantiating and populating it directly as per standard programming practices, or by "translating" an
existing model entity.

It's important to note that DTOs should stay within the realm in which they are intended. For example, a DTO
from the API package should not be used in the adapters, passed in through the rules, or used in manifest
processing. Such a DTO should be restricted to the API resources, controllers and directly utility classes
explicitly for API processing.


### Using the model translator

The easiest way of converting a model entity to a DTO is to use a model translator to do the work for you. A
```ModelTranslator``` is a mapper that manages ```ObjectTranslator``` instances and determines which
translators to use for a given translation task. To convert an entity with this method, we'll need a model
translator and one or more object translators.

A basic model translator implementation is the ```SimpleModelTranslator```, which implements the standard
functionality defined by the model translator interface. We can use this implementation for registering the
object translator(s) we'll be using.

```
    ModelTranslator modelTranslator = new SimpleModelTranslator();
```

Next we need some object translators to handle the actual type to type translation. For this example, we'll
translate ```Owner``` objects to ```OwnerDTO``` objects, for which we can use an ```OwnerTranslator```.

```
    OwnerTranslator ownerTranslator = new OwnerTranslator();
```

All we need to do is register the owner translator as a handler for the Owner to OwnerDTO translation:

```
    modelTranslator.registerTranslator(ownerTranslator, Owner.class, OwnerDTO.class);
```

Finally, with the translators in place, we can translate our owner entities by using the ```.translate```
method:

```
    Owner entity = <fetch owner entity from database>
    ...

    OwnerDTO dto = modelTranslator.translate(entity, OwnerDTO.class);
```

At this point, the dto is fully populated with data from the owner entity, and it's nested entities where
appropriate and necessary.


### Using the standard translator

Even easier than converting using the model translator method described above is to simply use the standard
translator. The ```StandardTranslator``` is a pre-defined and configured translator that contains translations
for all supported model entities straight out of the box. This can be instantiated directly, or injected by
the dependency injection framework.

Direct instantiation:
```
    ModelTranslator modelTranslator;

    ...

    this.modelTranslator = new StandardTranslator(...);
```

Dependency injection:
```
    @Inject
    public MyResource(ModelTranslator modelTranslator) {
        ...
        this.modelTranslator = modelTranslator;
        ...
    }
```

Note that when we use dependency injection, we're injecting it as a generic ```ModelTranslator``` rather than
the more specific ```StandardTranslator```

Once the translator is created, simply call the ```.translate``` method as we did in the previous example:

```
    Owner entity = <fetch entity from database>
    ...
    OwnerDTO dto = this.modelTranslator.translate(owner, OwnerDTO.class);
```

### Performing bulk object translation

At the time of writing, the model translator does not support true bulk translation. However, it does expose
a method for use with the Java 8 streaming API to process collections of objects.

The method in question is the ```.getStreamMapper```, which returns a mapper method to be used with the
```.map``` intermediate stream operation.

```
    Collection<Owner> entities = <fetch entity collection from database>

    Stream<OwnerDTO> dtoStream = entities.stream()
        .map(this.modelTranslator.getStreamMapper(Owner.class, OwnerDTO.class);
```

From this point, the stream can be iterated or terminated as normal. This is preferable to manual iteration
and translation using a loop, as it avoids the object translator lookup on every iteration.



## Designing and Implementing new DTOs

Designing a new DTO within this DTO framework is a three step process:

1. Design & create DTO
1. Design & create necessary object translators
1. Register the object translators with the StandardTranslator



### DTO Acceptance Criteria

1. A given interface must not contain any references to the `org.candlepin.model` Java package.
2. A given DTO must *not* return a type from the `org.candlepin.model` Java package.



### DTO Design Requirements

When creating DTOs for the new DTO framework, a number of design requirements should be followed to ensure
consistency and stability across the entire framework. The following requirements are listed in no particular
order, and should all be strictly followed, excempting only the most explicit and obscure circumstances.

- DTOs must contain, at minimum, a field containing its unique identifier (usually the DB ID)
- DTOs must contain a properly functioning copy constructor, clone method, equals method and hashCode method
- Collections contained within the DTO must be fully encapsulated
- Collections returned by accessors must be immutable collections or views
- Equality checks and hash code calculations must only use the primary identifier of any nested objects
- Join objects -- nested DTOs used only to map DTOs -- must use immutable references to their joined objects
- Mutators/Setters should return a self-reference to allow method chaining
- The standard implementation of a given DTO should have exactly two constructors: the default constructor
  and a copy constructor; subclasses may contain any constructors deemed necessary for their intended context


### Creating the object translators

Once a DTO has been created in accordance with the requirements above, the next step is to create the
necessary translators that will process or output the new DTO.

For each translation that will use this DTO, a translator implementing the ```ObjectTranslator``` interface,
typed with the input and output class of the translation. For example, the translator which handles owner to
owner DTO translation implements the interface: ```ObjectTranslator<Owner, OwnerDTO>```.

The ```ObjectTranslator``` interface defines four methods of two classes: ```translate``` and ```populate```.
The translate methods take a source object and output a new instance representing the translated object.
Similarly, the populate methods take a source object and a destination object, and update the destination
object with data from the source object. Both methods have a overloaded definition which also accepts a
model translator which can be used to translate nested objects within the source object.

The overlapping nature of the translate and populate operations allows most object translator implementations to
simply chain the translate operation into the populate operation rather than duplicate code. For example:

```
    @Override
    public OwnerDTO translate(Owner source) {
        return this.translate(null, source);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public OwnerDTO translate(ModelTranslator translator, Owner source) {
        return source != null ? this.populate(translator, source, new OwnerDTO()) : null;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public OwnerDTO populate(Owner source, OwnerDTO destination) {
        return this.populate(null, source, destination);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public OwnerDTO populate(ModelTranslator translator, Owner source, OwnerDTO dest) {
        // Do actual work here
    }

```

This leaves the populate method to handle the bulk of the menial copying work, without needing to worry about
duplicating the logic in multiple places.

As mentioned above, for objects which contain nested objects, the provided model translator can be used to
offload the translating of these nested objects back to the appropriate translator. For instance:

```
        if (modelTranslator != null) {
            Pool pool = source.getPool();
            dest.setPool(pool != null ? modelTranslator.translate(pool, PoolDTO.class) : null);
        }
        else {
            dest.setPool(null);
        }
```

This is optional behavior, and should default to null in cases where processing nested objects is either not
provided, or when a model translator is not available.


### Registering the translators with the standard translator

Finally, once the translators are complete, they should be added to the standard translator. At the time of
writing, this is a matter of simply updating the default constructor of the ```StandardTranslator``` to
register the new translator during instantiation:

```
        this.registerTranslator(new MyObjectTranslator(), InputObject.class, OutputObject.class);
```

This will translation of the input object via the standard translator, without any additional work on the
part of developers who will be using it.

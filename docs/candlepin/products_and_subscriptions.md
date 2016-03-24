---
title: Products, Subscriptions and Entitlements
---
{% include toc.md %}


The ultimate goal of an owner is to use a piece of software on theirs *consumers*. 

The diagram below shows simplified example of Candlepin usage. The owner, organization Mediatechnology, owns two developer machines (consumers) that need to use Fedora 22 and JBoss Application Server. The Mediatechnology can buy a subscription named "Java Developer Subscription" that provides "Marketing_Java_Dev_Product", this Marketing Product in turn provides the two required Engineering Products. Candlepin helps in this situation by bookkeeping information about: 

* the owner (name, credentials to log in into Candlepin)
* the consumers (developer machines). Information about installed software is also tracked, they are so called *facts*: CPUs, amount of RAM, etc.
* subscription that the owner bought
* *consumption* of a subscription for each given developer machine. The act of consumption and the object that tracks the consumption is called Entitlement

Based on the above information, Candlepin can easily determine which consumers (developer machines) for owner Mediatechnology are sufficiently covered and which lack necessary subscriptions.

The diagram is still very incomplete, at the end of this page, this diagram will be extended to more accurately align with how Candlepin works

{% plantuml %}
actor owner_Mediatechnology
frame Java_Developer_Subscription {
  artifact Marketing_Java_Dev_Product  
  artifact JBoss_Application_Server
  artifact Fedora_22
  Marketing_Java_Dev_Product -->  JBoss_Application_Server : provides
  Marketing_Java_Dev_Product -->  Fedora_22 : provides
}
artifact JBoss_Application_Server
artifact Fedora_22
node Developer_machine_1
node Developer_machine_2
owner_Mediatechnology --> Java_Developer_Subscription : buys
owner_Mediatechnology --> Developer_machine_1 : owns
owner_Mediatechnology --> Developer_machine_2 : owns
{% endplantuml %}


## Engineering and Marketing Products
We have already seen examples of Engineering Product:

* JBoss Application Server
* Fedora 22

These Engineering Products have numeric IDs in Candlepin (e.g. 23) to identify them. Each engineering product is also tied with Content. A Content is a set of Content Repositories such as YUM repositories that contain the product binaries or related software. 

Engineering Products are tied to so called Marketing Products. This is done to bundle more Engineering Product together under one Marketing Product. Marketing Products have key-value attributes  which control the business logic in Candlepin. An example of attribute is an integer valued attribute 'sockets'. The value of this attribute specifies maximum amount of CPU cores that a consumer is allowed to have when using the Marketing Product. The Marketing products have alpha-numeric ID also reffered to as SKU (e.g. MKT22321) and carry no Content. 

Another concepts in Candlepin are: *Derived Marketing Product* and *Derived Engineering Product*. These are special usages of Marketing/Engineering products in virtualized environment. In Virtualized Environment, Candlepin can distinguish between host consumers (computers that act as Hypervisors in virtualization) and guest systems (virtual machines that are provisioned on the Hypervisors). In some specific cases, it might be desireable that the guest systems will not directly use the Marketing Product that a customer bought with a subscription, but the subscription has another so called Derived Marketing Product that is dedicated to be used for the guest system. 

## Subscriptions
Subscription is a right to use a given Marketing Product. The subscription bundles:

* Marketing Product
* Provided Engineering Products
* (optional) Derived Marketing Product
* (optional) Provided Derived Engineering Products

There are different types of Subscriptions. The type of the Subscription is not explicitly stored in any transfer object, but it is an abstract property of Subscription that can be infered from attributes that the bundled Marketing Product contains. The most common types of the Subscriptions are: Plain, Stacked, Virt Limit, Instance Based, Storage Band, Derived. More information about the types can be found [here](subscription_types.html)

Subscriptions are created in Candlepin by the administrator. In Standalone deployment of Candlepin, the administrator uses so called Subscription Adapter to load Subscriptions into Candlepin. 

## Subscription Pool
It might be suprising that Candlepin doesn't actually store Subscriptions databse. The actual object that Candlepin stores in the database is called Subscription Pool.

Subscription Pool (also referred to simply as a Pool) is very similar to Subscription. Pool is also a right to use a given Marketing Product and the Pool also bundles Products in very much the same way as Subscription does. The reason we store Subscription Pool instead of Subscription is mainly technical. However it should be clear that apart from the administrators import of Subscription, Candlepin does not perform business logic on the Subscriptions, but it only uses Subscription Pools.

For each subscription that the administrator defines, at least one Subscription Pool is created in Candlepin. Pools can be of different types based on how the they are created. The pool type is recorded as a database flag. Basic types include: Master Pool, Derived Pool, Stack Derived Pool, Unmapped Guest Pool, Virt Bonus Pool. You can find list of pool types [here](pool_types.html)

## Entitlement
Entitlement represents a consumption of a pool for a given consumer. The consumption takes place at a specific time. Note that the Subscription Pool has integer value *quantity* and consumption decreases the quantity of the Pool. 

An entitlement can be revoked, which returns the used quantity back to the pool and removes the entitlement object from the Candlepin database.

The consumption of a Subscription Pool is done, like most of the interactions with Candlepin, using a REST API call. However, the end-user typically uses one of more user friendly interfaces such as Python based thick client called Subscription Manager. The Subscription Manager is invoked directly from the system (consumer). The Subscription Manager can detect installed Engineering Products on the machine and thus can make it is easier for the user to choose which Pools to consume. This process is called *manual attach* of a subscription pool. 
Another possibility to consume a Pool is *auto attach*. Invoking this operation for a given consumer causes Candlepin server to attempt to find the best fit of available subscription pools to cover the consumer’s installed engineering products. Note that prior to running this operation, it is necessary that the information about installed engineering products is provided to Candlepin. The information may be provided by Subscription Manager.

## Example
The following diagram shows a basic situation where owner Mediatechnology buys a Java Developer Subscription. That subscription triggers creation of a new master Subscription Pool: *Java Dev Pool*. In this example, Mediatechnology has two consumers, that want to consume the Pool. The Java Developer Subscription is of type *plain* which means that Java Dev Pool will need to have at least quantity of 2 so that both consumers dev1 and dev2 are satisfied. The two consumptions of the Java Dev Pool will cause creation of two entitlements in Candlepin: Entitlement1 and Entitlement2. Each entitlement is tied to the specific Pool and to a specific Consumer.


{% plantuml %}
actor owner_Mediatechnology

frame Java_Developer_Subscription {
  artifact Mkt_Product_Java_Dev_Sub
  artifact Engineering_Prod_JBoss_AS
  artifact Engineering_Prod_Fedora_22
  Mkt_Product_Java_Dev_Sub --> Engineering_Prod_JBoss_AS : provides
  Mkt_Product_Java_Dev_Sub --> Engineering_Prod_Fedora_22 : provides
}

frame Java_Dev_Pool {
  artifact Mkt_Product_Java_Dev_Pool
  artifact Eng_Product_JBoss_AS
  artifact Eng_Product_Fedora_22
  Mkt_Product_Java_Dev_Pool --> Eng_Product_JBoss_AS : provides
  Mkt_Product_Java_Dev_Pool --> Eng_Product_Fedora_22 : provides
}

node Consumer_dev1
node Consumer_dev2
owner_Mediatechnology --> Java_Developer_Subscription : buys
Java_Developer_Subscription --> Java_Dev_Pool : causes creation of
owner_Mediatechnology --> Consumer_dev1 : owns
owner_Mediatechnology --> Consumer_dev2 : owns
artifact Entitlement1
artifact Entitlement2
Consumer_dev1 --> Java_Dev_Pool : consumes
Consumer_dev1 --> Entitlement1 : consumption created
Entitlement1 --> Java_Dev_Pool : decreases quantity of
Consumer_dev2 --> Java_Dev_Pool : consumes
Consumer_dev2 --> Entitlement2 : consumption created
Entitlement2 --> Java_Dev_Pool : decreases quantity of
{% endplantuml %}


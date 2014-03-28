---
layout: default
title: JSON and JAXB
---
{% include toc.md %}

Candlepin outputs JSON using JAXB. There is a limitation in what JAXB can
'figure out' when it comes to returning Lists of objects.

# List objects
Returning a List of objects doesn't quite work.

```java
@GET @Path("/listobjects")
@Produces(MediaType.APPLICATION_JSON)
public List<Object> listObjects() {
    return ObjectFactory.get().listObjectsByClass(getApiClass());
}
```

This results in an error, because there is no writer for Objects and JAXB doesn't know that it is really a User.

```text
A message body writer for Java type, class
 java.util.LinkedList, and MIME media type, application/json, was not found
```

# List base class method
It is useful to return your model using a List of the base classes i.e. List<BaseModel>.

```java
@GET @Path("/listbasemodel")
@Produces(MediaType.APPLICATION_JSON)
public List<BaseModel> listUsers2() {
    List<Object> u = ObjectFactory.get().listObjectsByClass(getApiClass());
    List<BaseModel> users = new ArrayList<BaseModel>();
    for (Object o : u) {
        users.add((BaseModel)o);
    }
    return users;
}
```

Unfortunately, this results in JSON being output for just the base class and does not
try to determine the actual type of the class in this case User object. The resulting
JSON shows what you get:

```json
{"baseModel":[null,
    null,
    {"uuid":"78ff6590-ae2d-4926-901a-b650a4142399"},
    {"uuid":"0c7b5169-cfe5-4916-ae47-1de066a3102d"}]}
```

# List Wrapper method
Create a wrapper class for the List of objects. Here is Users which wraps a List\<User\>.

```java
@XmlRootElement
@XmlAccessorType(XmlAccessType.PROPERTY)
public class Users {
    @XmlElement(required = true)
    public List<User> userList;
}
```

The GET method is done as follows:

```java
@GET @Path("/listusers")
@Produces(MediaType.APPLICATION_JSON)
public Users listUsers() {
    List<Object> objects = ObjectFactory.get().listObjectsByClass(getApiClass());
    Users users = new Users();
    users.userList = new ArrayList<User>();
    for (Object o : objects) {
        users.userList.add((User)o);
    }
    return users;
}
```

This will yield the correct JSON output:

```json
{"userList":[{"login":"test-login","password":"redhat"},
    {"login":"test-login","password":"redhat"},
    {"uuid":"78ff6590-ae2d-4926-901a-b650a4142399","login":"candlepin","password":"cp_p@s$w0rd"},
    {"uuid":"0c7b5169-cfe5-4916-ae47-1de066a3102d","login":"candlepin","password":"cp_p@s$w0rd"}]}
```

# List actual object
Returning a list of the actual objects works as expected as well:

```java
@GET @Path("/uselist")
@Produces(MediaType.APPLICATION_JSON)
public List<User> listUsers1() {
    List<Object> u = ObjectFactory.get().listObjectsByClass(getApiClass());
    List<User> users = new ArrayList<User>();
    for (Object o : u) {
        users.add((User)o);
    }
    return users;
}
```

This code results in the following JSON:

```json
{"user":[{"login":"test-login","password":"redhat"},
    {"login":"test-login","password":"redhat"},
    {"uuid":"78ff6590-ae2d-4926-901a-b650a4142399","login":"candlepin","password":"cp_p@s$w0rd"},
    {"uuid":"0c7b5169-cfe5-4916-ae47-1de066a3102d","login":"candlepin","password":"cp_p@s$w0rd"}]}
```

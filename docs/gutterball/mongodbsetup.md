---
categories: Usage
title: MongoDB Setup
---
{% include toc.md %}

# MongoDB Setup

By default, MongoDB is installed in no-auth mode. If running gutterball in production, make sure to run MongoDB in a secure environment.

Gutterball currently only supports authenticating with MongoDB using basic authentication. If you would like to run MongoDB with basic auth, see below. 

For more information on how to properly set up your gutterball database user, please see the <a href="http://docs.mongodb.org/manual/security/" target="_blank">MongoDB Documentation</a>.

## Installing MongoDB (Fedora)

### Install from the Fedora Repos (older version)

```
$ sudo yum install mongodb mongodb-server
```

### Install Latest Release
Follow steps outlined <a href="http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/" target="_blank">here</a>

## Setup Auth Mode

For more information on how to properly set up your gutterball database user, please see the <a href="http://docs.mongodb.org/manual/security/" target="_blank">MongoDB Documentation</a>.

**NOTE: The following steps are for MongoDB from the Fedora repos (2.4.6). The commands for the latest version are a little different. Please refer to the MongoDB documentation.**

Enabling Auth Mode.

```
$ sudo vim /etc/mongod.conf

# Uncomment the following line
auth=true
```

Restart mongodb

```
 $ sudo systemctl restart mongod
```

Create an admin user in mongodb.

```
$ mongo

> use admin
> db.addUser("admin", "admin")
```

Create a user for the gutterball db.

```
$ mongo

> use admin
> db.auth("admin", "admin")
> use gutterball
> db.addUser("gutterball", "password")
```

Edit gutterball's default.properties file so that it reflects your gutterball db user's credentials.

```
gutterball.mongodb.username = gutterball
gutterball.mongodb.password = password
```

Restart tomcat
```
sudo systemctl restart tomcat
```

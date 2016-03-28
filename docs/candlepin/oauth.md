---
title: OAuth Authentication
---
{% include toc.md %}

# OAuth Authentication Intro

Candlepin has the ability to authenticate calls using the OAuth protocol.  You
can find more information about the specification [here](http://oauth.net/).
Another good [OAuth Guide at hueniverse.com](http://hueniverse.com/oauth/) is
also recommended.

There are two main flavors of Oauth. The most popular approach is to use a
3-legged approach which involves a user, and a third party app (called
consumer) accessing a network (i.e. twitter, facebook) on behalf of the user.
Using this protocol, a user can let a client (consumer) access data available
on an application without revealing user credentials. OAuth is primarily
designed to allow 3rd party developers to do actions on behalf of authenticated
users. There is also a two legged approach that allows applications to sign
requests, basically validating that those requests come from the application.
The two legged approach is the initial implementation offered by Candlepin's
API.

The two "legs" in 2-legged OAuth represent the caller (your code) and a backend
system, known as the provider in OAuth terms, that being being Candlepin. Using
the 2-legged protocol, these two applications are able to securely exchange
information through OAuth signed requests. 

The setup of two legged OAuth requires there to be a consumer key/secret that
is known by both the consumer and provider (aka, client and server). The
consumer will generate multiple oauth parameters that are generally sent in the
http authorization headers but this can be tweaked depending on the oauth
plugin/gem/jar/lib that the consumer is using.  The Authorization header afer
application of the OAuth algorithm ends up looking like:

```http
Authorization = OAuth realm="",
  oauth_consumer_key="bc906fac81f581c3c96a",
  oauth_nonce="9dc8fbca0e51842e7449",
  oauth_signature="Ky%2F6LlDHpHX1EZMRi5mfUl9vxqY%3D",
  oauth_signature_method="HMAC-SHA1",
  oauth_timestamp="1254282755",
  oauth_version="1.0"
```

The consumer generated oauth_signature comes from a base string and a key
generated from the consumer and token secrets. The base uri string comes from
the following parts:

  * A HTTP method (POST, DELETE, GET, PUT). Depends on what call we are making.
    For example, POST would be used to create a repo in Candlepin. 
  * The request URL (without query parameters). This is the base URL for the
    API call, percent-encoded. Include the port if it is other than 80 for HTTP
    or 443 for HTTPS.
  * Concatenated list of all parameters sent, including OAuth parameters and
    API parameters. It should be in alphabetical order and concatenated
    together with ampersand separators. Percent-encode parameters before
    concatenating them, and then percent-encode the entire string.

An example of a base string would look something like this:

```text
GET&http%3A%2F%2Fmycandlepin.example.com%2Ffoo%2F&oauth_consumer_key%3Dbc906fac81f581c3c96a%26oauth_nonce%3D9dc8fbca0e51842e7449%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1254282755%26oauth_version%3D1.0
```

Next, the consumer generates the digest value of the base string with HMAC-SHA1
(or RSA-SHA1) and encodes the digest value with BASE64. If HMAC-SHA1 is used,
the shared key will be the string with the Consumer Secret and empty Token
Secret (since this is 2 legged) connected with '&' character. 

The base string and generated key would then be passed to the crypto algorithm:

```text
hash_hmac('SHA1', base_string, key)
```

The function will return a 20-character ASCII string. Because many of the
characters in the string can't be sent in a URL, we need to get a base-64
encoded version of our string (base64 encoding). The final step in preparing
the signature is to make sure that it is percent-encoded.

The oauth_signature would look something like `Ky/6LlDHpHX1EZMRi5mfUl9vxqY=`

# How To
First you need to enable OAuth on your Candlepin server by configuring the
secret and key.  These string keys are configured in Candlepin's
`/etc/candlepin/candlepin.conf` file with the following values:

```properties
candlepin.auth.trusted.enabled = true
candlepin.auth.ssl.enabled = true
candlepin.auth.oauth.enabled = true
candlepin.auth.oauth.consumer.myconsumer.secret = guessme
```

The above example sets the consumer key to "myconsumer" and the secret to
"guessme". After adding those values to the configuration just restart Tomcat:

```console
# service tomcat6 restart
```

Now you need to utilize some code in order to properly formulate a OAuth style
request.  See below for a Ruby example.

# OAuth authentication through Ruby code
Here we use the oauth gem to formulate a REST style request to Candlepin's API
with OAuth authentication.

The key and secret **MUST** match what is in Candlepin's
`/etc/candlepin/candlepin.conf` file.
{:.alert-caution}

Requirements:
 
* Must use the same key/secret pair from candlepin.conf
* Must include the cp-user header to identify which user you wish to authenticate with.

```ruby
#!/usr/bin/ruby

require 'rubygems'
require 'oauth'

consumer_key = "example-key"
consumer_secret = "example-secret"

# Setup a new Consumer
consumer = OAuth::Consumer.new(
             consumer_key,
             consumer_secret,
             :site => "https://localhost",
             :request_token_path => "",
             :authorize_path => "",
             :access_token_path => "",
             :http_method => :get
           )

oauth_access = OAuth::AccessToken.new consumer
response = oauth_access.get("/candlepin/owners", { 'cp-user'=>'admin' })

#show json data
puts response.body
```

# Notes and Considerations
The implications of this approach are:
 
* Be aware that anyone with the shared key and secret combination can freely
  authenticate to your Candlepin instance's API.  Keep these secrets secure.
* Be also aware that because we are not yet using a Token in addition to the
  signature that users can act as *any* pulp user by adjusting the _cp-user_
  header in the requests.  

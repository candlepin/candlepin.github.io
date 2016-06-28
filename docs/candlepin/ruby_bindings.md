---
title: Ruby Bindings for Candlepin
---
## Clients
The Candlepin Ruby bindings are designed to be invoked off of a client object.
Currently, there is a NoAuthClient, BasicAuthClient, X509Client, and
TrustedAuthClient to match the various types of authenticated interactions
Candlepin can expect to have with a client.  (There is a stub for an OAuthClient
but I have not yet implemented it).

### NoAuthClient
Every client class descends from NoAuthClient so each client class can accept
the following options in a hash:

* host - Defaults to `localhost`
* port - Defaults to `8443`.  Should be provided as an int
* context - Defaults to `/candlepin`.  Leading slash is not required
* use_ssl - Defaults to `true`!
* insecure - Defaults to `true`!  E.g. self-signed certs are accepted by
  default.
* connection_timeout - Defaults to 3 seconds
* fail_fast - If the client should throw an exception on a non-200

Additionally, the other clients have additional options.

### TrustedAuthClient
* username - user to identify as

### BasicAuthClient
* username
* password

### X509Client
* client_cert - OpenSSL::X509:Certificate object
* client_key - OpenSSL::PKey::PKey object

The `X509Client.from_files` and `X509Client.from_consumer` factory methods are
provided to construct a client given two PEM files or a blob of consumer JSON.

### Client Design
A client wraps an [HTTPClient](https://github.com/nahi/httpclient) instance and
exposes many of the HTTPClient methods through delegation.  The actual
HTTPClient instance is available via the `raw_client` method if you need it.

The logical Candlepin methods are implemented in modules and inserted into
the Client classes via `include`.

## Handy Client Methods
* `client.debug!` will set the client instance to print out the HTTP request and
  response.  Disable with `client.debug = false`
* `client.fail_fast = true` will set the client to fail raise an exception on a
  non-200 response.  Useful to set before running several operations that must
  succeed
* `client.reload` will reload the underlying HTTPClient instance.  You need to
  call this method if you change attribute values (e.g. hostname) via the
  accessor methods
* `client.uuid = XXX` can be used to assign a specific consumer uuid to a client
  so that you don't have to keep passing it in
* `client.key = XXX` like the above, but with an owner key

## Candlepin Methods
General notes:

  * Options are specified via an option hash: E.g. `client.delete_consumer(:uuid
    => '123')`
  * The methods are generally strict about the options hash.  It cannot contain
    keys that the method does not recognize (to help you catch typos, etc.
    early).  Additionally, some values in the options hash are required or have
    other validation performed on them.  Validation failure results in an
    exception.
  * Nearly all the methods return an
    [HTTP::Message](http://www.rubydoc.info/gems/httpclient/HTTP/Message) object
    that represents the entire response.  That includes headers, status code,
    and response body.
  * Many times you will want only the content of a successful request and an
    error otherwise.  For this scenario use `ok_content` off the HTTP::Message.
    The response body will be returned if the status was a 2xx otherwise an
    exception is raised.  E.g. `client.get_status.ok_content`

The methods generally follow the below conventions:

  * Accepted options are strictly snake case.  Any conversion to camel case is
    handled internally
  * If request is a GET, method begins with `get`
  * If request is a DELETE, method begins with `delete`
  * If request is a POST, method begins with `create`, `add`, or `post`
  * If request is a PUT, method begins with `update` or `put`
  * Reasonable defaults are provided so that you only need to add things you
    care about to the options hash.

Notable methods:

  * `register_and_get_client` will register a consumer and instead of returning
    the HTTP response, returns a X509Client bound to the created consumer.
  * `bind` to bind an entitlement to a consumer.

## Example

```ruby
#! /usr/bin/env ruby

require './candlepin'

RANDOM_CHARS = [('a'..'z'), ('A'..'Z'), ('1'..'9')].map(&:to_a).flatten
def rand_string(prefix = '', len = 9)
  rand = (0...len).map { RANDOM_CHARS[rand(RANDOM_CHARS.length)] }.join
  prefix.empty? ? rand : "#{prefix}-#{rand}"
end

ORG='TESTCOMPANY-9516528'.freeze

client = Candlepin::BasicAuthClient.new(
  :username => 'admin',
  :password => 'admin'
)

client.key = ORG

PRODUCT_ID = 'MKT641315117378'.freeze

product = client.get_owner_product(
  :product_id => PRODUCT_ID[3..-1],
).ok_content

consumers = []
10.times do
  consumers << client.register(
    :name => rand_string('consumer'),
    :facts => { 'system.certificate_version' => '3.2' },
  ).ok_content
  puts "Registered #{consumers.last[:id]}"
end

consumers.each do |c|
  res = client.update_consumer(
    :uuid => c[:uuid],
    :installed_products => {
      :productName => product[:name],
      :productId => product[:id],
    }
  )
  res2 = client.update_consumer(
    :uuid => c[:uuid],
    :installed_products => {
      :productName => product[:name],
      :productId => product[:id],
    }
  )
  puts "Updates: #{res.status_code} and #{res2.status_code}"
end

consumers.each do |c|
  client.bind(
    :async => false,
    :uuid => c[:uuid],
    :product => PRODUCT_ID,
  ).ok_content
end

sleep 5

consumers.each do |c|
  res = client.delete_consumer(
    :uuid => c[:uuid]
  )
  puts "Deleted #{c[:uuid]} - #{res.status_code}"
end
```

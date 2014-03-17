---
layout: default
categories: thumbslug
title: Testing
---
{% include toc.md %}

## Testing As a Developer
Run the suite of tests with:

```console
$ buildr spec
```

You can also run the application for manual testing with:

```console
$ buildr serve
```
When you are doing thumbslug development, the easiest way to test a change is
to simply run the spec tests. In order to view the log4j log during spec
execution, you can apply the following diff to
`src/main/resources/log4j.properties`, which will add an stderr appender in
addition to the stdout appender. You cannot simply redirect the stdout
appender, since stdout is used by the spec test to handle process startup.

```diff
-log4j.rootLogger=WARN,RootAppender
+
+log4j.appender.stderr=org.apache.log4j.ConsoleAppender
+log4j.appender.stderr.layout=org.apache.log4j.PatternLayout
+log4j.appender.stderr.layout.ConversionPattern=%d{MMM dd HH:mm:ss} [%t] %-5p %c - %m%n
+log4j.appender.stderr.Target = System.err
+
+log4j.rootLogger=WARN,RootAppender,stderr
```

During regular testing, you don't have to test against a real CDN since you can
use the provided webrick. In order to add mock-CDN functionality, you can add a
servlet to thumbslug_common.rb like so:

```ruby
class FiveHundred < WEBrick::HTTPServlet::AbstractServlet

  def do_GET(request, response)
    response.status = 500
    response['Content-Type'] = "text/plain"
    response.body = 'Error! a 500 error'
  end
end
```

Sometimes it is helpful to keep the webrick running, in order to test your mock
servlets. Just throw a `sleep(large_integer_here)` at the end of the
`before(:all)` code block in the test suite of interest. Don't forget to
comment out the `around(:each)` timeout!

If you want to use the Java debugger, you can use the spec methods but invoke
them directly via irb or [pry](http://pryrepl.org/)

```console
$ pry
[1] pry(main)> load './spec/thumbslug_common.rb'
=> true
[2] pry(main)> tslug = ThumbslugMethods.create_thumbslug({}, true)
=> #<IO:fd 9>
[3] pry(main)> webrick_pid = ThumbslugMethods.create_httpd(true)
Started webrick
=> 19547
[4] pry(main)> ThumbslugMethods.get('https://localhost:8088/lorem.ipsum')
=> #<Net::HTTPOK 200 OK readbody=true>
[5] pry(main)> Process.kill('INT', tslug.pid)
=> 1
[6] pry(main)> Process.kill('INT', webrick_pid)
=> 1
```

Or with your running thumbslug, you can use curl.

```console
$ curl --cacert spec/data/CA/candlepin-ca.crt --cert spec/data/spec/test-entitlement.pem  -v https://localhost:8088/ping
* Adding handle: conn: 0xfbcda0
* Adding handle: send: 0
* Adding handle: recv: 0
* Curl_addHandleToPipeline: length: 1
* - Conn 0 (0xfbcda0) send_pipe: 1, recv_pipe: 0
* About to connect() to localhost port 8088 (#0)
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 8088 (#0)
* Initializing NSS with certpath: sql:/etc/pki/nssdb
*   CAfile: spec/data/CA/candlepin-ca.crt
  CApath: none
* NSS: client certificate from file
* 	subject: CN=8a8d01e9442cfe7701442d0227b8170a
* 	start date: Feb 13 00:00:00 2014 GMT
* 	expire date: Feb 13 00:57:58 2030 GMT
* 	common name: 8a8d01e9442cfe7701442d0227b8170a
* 	issuer: L=Raleigh,C=US,CN=arkham.usersys.redhat.com
* SSL connection using TLS_DHE_RSA_WITH_AES_128_CBC_SHA
* Server certificate:
* 	subject: L=Raleigh,C=US,CN=localhost
* 	start date: Feb 18 17:16:36 2014 GMT
* 	expire date: Jul 06 17:16:36 2041 GMT
* 	common name: localhost
* 	issuer: L=Raleigh,C=US,CN=arkham.usersys.redhat.com
> GET /ping HTTP/1.1
> User-Agent: curl/7.32.0
> Host: localhost:8088
> Accept: */*
> 
< HTTP/1.1 204 No Content
< 
* Connection #0 to host localhost left intact
```

When you are using these methods, **you must connect to localhost and not
127.0.0.1.** We are doing peer verification, so the name in the CN of the
host's cert must match the host you are connecting to.
{:.alert-caution}

## Convert a pem key/cert to p12
```console
$ openssl pkcs12 -export -in cert.pem -inkey cert.pem -out client.p12
enter password as password/password
```

---
title: Reporting an Error
---
If you have encountered an error or stack trace from Candlepin, the following
instructions will help gather required info to include in bug report. The
following relies on new logging features introduced in Candlepin 0.8.30 and
higher.

1. If the issue is reproducible, and you have control of the Candlepin server,
   enable Candlepin debugging by placing the following in
   /etc/candlepin/candlepin.conf:

   ```
   log4j.logger.org.candlepin=DEBUG
   ```

   Then restart your servlet container. For example:

   ```
   sudo service tomcat6 restart
   ```

   If the issue is not reproducible or you do not have the permission to do
   this, that is ok, it just will provide additional details.
1. Identify the request UUID which can be found in a number of places.
   * In the response from the server:

     ```
     {
       "displayMessage" : "Organization with id kahsdkjh could not be found.",
       "requestUuid" : "9164da92-2fd7-4f08-8663-989ca475dac4"
     }
     ```

   * In the log entry with the stack trace. Errors and warnings are logged to
     /var/log/candlepin/error.log for easy access, but will also be present
     with more logging in the main log file at /var/log/candlepin/candlepin.log.

     ```
     2013-10-09 15:31:40,572
     [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] ERROR
     org.candlepin.resource.ConsumerResource - Problem creating unit:
     javax.persistence.PersistenceException:
     org.hibernate.exception.ConstraintViolationException: Could not execute
     JDBC batch update
     ```

1. If it is feasible, include/attach/upload the entire candlepin.log file.
1. If candlepin.log is too large, gather up all log statements for the given request UUID.

   ```
   $ cat /var/log/candlepin/candlepin.log | grep cbf6fef0-7f6c-45f6-9320-2eb8b424e398
   2013-10-09 15:31:40,529 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] INFO  org.candlepin.servlet.filter.logging.LoggingFilter - Request: verb=POST, uri=/candlepin/consumers?
   2013-10-09 15:31:40,533 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resteasy.interceptor.AuthInterceptor - Authentication check for /consumers
   2013-10-09 15:31:40,533 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resteasy.interceptor.OAuth - Checking for oauth authentication
   2013-10-09 15:31:40,533 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resteasy.interceptor.BasicAuth - check for: willy-wQQyy2A4 - password of length #8 = <omitted>
   2013-10-09 15:31:40,534 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resteasy.interceptor.BasicAuth - principal created for user 'willy-wQQyy2A4
   2013-10-09 15:31:40,569 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.auth.interceptor.SecurityInterceptor - Invoked security interceptor public org.candlepin.model.Consumer org.candlepin.resource.ConsumerResource.create(org.candlepin.model.Consumer,org.candlepin.auth.Principal,java.lang.String,java.lang.String,java.lang.String) throws org.candlepin.exceptions.BadRequestException
   2013-10-09 15:31:40,569 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.auth.interceptor.SecurityInterceptor - Allowing invocation to proceed with no authentication required.
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.auth.Principal - org.candlepin.auth.UserPrincipal principal checking for access to: Owner [id: 40288198419e68cb01419e7d1532292c, key: owner-fy6sXxmi]
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.auth.Principal -  perm class: org.candlepin.model.OwnerPermission
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.auth.Principal -   permission granted
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resource.ConsumerResource - Got consumerTypeLabel of: system
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resource.ConsumerResource - incoming facts:
   2013-10-09 15:31:40,570 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] DEBUG org.candlepin.resource.ConsumerResource - Activation keys:
   2013-10-09 15:31:40,571 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] WARN  org.hibernate.util.JDBCExceptionReporter - SQL Error: 1062, SQLState: 23000
   2013-10-09 15:31:40,571 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] ERROR org.hibernate.util.JDBCExceptionReporter - Duplicate entry 'ALF' for key 'cp_consumer_uuid_key'
   2013-10-09 15:31:40,571 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] ERROR org.hibernate.event.def.AbstractFlushingEventListener - Could not synchronize database state with session
   2013-10-09 15:31:40,572 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] ERROR org.candlepin.resource.ConsumerResource - Problem creating unit:
   2013-10-09 15:31:40,644 [req=cbf6fef0-7f6c-45f6-9320-2eb8b424e398,org=test_owner-trF37X7y] INFO  org.candlepin.servlet.filter.logging.LoggingFilter - Response: status=400, content-type="application/json", time=115ms
   ```

1. If the issue is in any way related to transactions or concurrency, either
   include the whole log file, or also grep for the org:

   ```
   $ cat /var/log/candlepin/candlepin.log | grep org=test_owner-trF37X7y
   ```

   You may need to filter down the results to just log entries around the time
   of the error. This may be important as we often need to know exactly what
   else was going on at the time a transaction failed to determine how to
   reproduce.
1. Grab the full text of the stack trace, as the above grep only picks up the first line.
1. Include this information in your error/bug report.

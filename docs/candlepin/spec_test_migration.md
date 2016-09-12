---
title: Spec test migration
---
{% include toc.md %}

## Migration <TDLR>
* Effective immediately (11th March 2016), the spec tests in `server/spec` are being moved to `server/old_spec` and the supporting ruby client `server/client/ruby/candlepin_api.rb` is being replaced by `server/client/ruby/candlepin.rb`.

* The rest client refactor is complete and has been merged into master, but the spec tests refactor is in progress and is being worked in the branch `awood/spec-refactor`

* Once that branch is merged to master ( TODO: update this doc then ), the existing spec tests and ruby client will be  deprecated.

* After that merge, Any new tests should be added only to `server/spec`.

* Due to changes in candlepin, if any changes need to be made to `server/old_spec`, that spec test should be ported to `server/spec` as a part of that PR.

* Both `server/client/ruby/candlepin_api.rb` and `server/client/ruby/candlepin.rb` need to be maintained until `candlepin_api.rb` is deleted.

* Buildr rspec will continue to run spec tests against both old and new spec tests.

* The new rest client and spec tests are now style checked via Rubocop.

  ```console
  $ buildr rubocop
  ```
* Style issues could be fixed using the auto_correct task:

  ```console
  $ buildr rubocop:auto_correct
  ```
* Note: Not all the new rest client methods have been thoroughly tested; we are relying on the spec test refactor to improve the reliability of the client. Until then, this client is for candlepin developers' use only.

## Todo Tasks
* Port hostedtest rest client APIs to the new client
* In the new rest client need to move the helper classes Message, JSONClient, Candlepin::Util, Candlepin::API,etc ( basically everything but the resource classes) to their respective files.
* We need to move the custom matchers from the test file to a utility that spec tests can use.
* Debug is an instance variable on the client, which means we no longer have a global debug. The newer debug is very convenient, but perhaps we could keep the old option of a global debug too? When my test_candlepin.rb failed, I had to debug! on all the clients to find out where the problem was, and wished there was a global debug
* Figure out a way to run `server/client/ruby/test/test_candlepin.rb` with every PR. perhaps add a new task or update rspec task?

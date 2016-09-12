---
title: Server-Side Entitlement Status
---
{% include toc.md %}

# Server-Side Entitlement Status
Once upon a time the client carried a complete implementation of code for
determining entitlement status (red/yellow/green) to accommodate the
disconnected use case. Unfortunately, because this was eventually also needed
server side for healing/auto-attach and management tools, this logic had to be
duplicated in the candlepin server as well. This hampered efforts to roll out
new entitlement features because all work had to be done twice, kept in sync,
and the client would need to be updated before the feature was usable.

However, we will be transitioning to a model where the server is responsible
for determining this status and the client will request it on the fly. This
allows the logic to exist in only one place and language, and enables us to
change it in a centralized fashion by publishing new JavaScript rules in
Candlepin. Once uploaded in hosted, these rules will begin to trickle out to
downstream Candlepin servers in SAM/SE through the manifests. 

The upload in hosted is as before, IT basically can either roll out a new
Candlepin RPM containing new rules, or use an API call to update them on the
fly.

For disconnected systems, the client will report that entitlement status is
effectively "unknown". We will likely indicate whether we have access to the
content for an installed product however. (pending mockups) The only compliance
logic remaining in subscription manager will be this check if a product has a
certificate that grants access to its content, and some rudimentary date
comparisons in some situations when we need to display a certificate is expired
or about to expire. All calculations of socket/ram coverage and
red/yellow/green will defer to the server.

For a registered system, all behaviour should be exactly as before, only now
the client is requesting status from the server on the fly rather than
calculating it locally.

Detailed below there will be a caching mechanism we can fall back on in the
event the server is temporarily unreachable.

## Tasks
1. Add GET `/consumers/{uuid}/compliance` to python-rhsm connection class.
1. Add method to get list of installed product IDs to product directory if not
   there already.
   1. This should replace some uses of the cert sorter which will now be a
      little slower (as they require server communication).
1. Encapsulate this within existing `CertSorter` Python class. 
   1. Will have to pass in a connection object, these are created in relatively
      few places. When updating constructors, look for any uses which are just
      getting a list of installed IDs and switch to using the product directory
      method mentioned above instead.
   1. When creating/reloading, we will request status from the server and
      expose the exact same information via the existing Python object. This
      will impact performance some but the reload should only be called when
      entitlement status has changed.
1. When system is not registered:
   1. Modify cert sorter to indicate this.
   1. Update uses of cert sorter to show *no* indication of red/green/yellow.
   1. Display prominently in UI and CLI that the system is not registered and
   do not show entitlement status. (pending mockups from mreid) 
      * May also need a way to show that a product is technically covered in
        that we can access its content, but we can't use red/green/yellow as
        this will be confusing to users.
1. Eliminate all old entitlement status calculation code in client, and all
tests for it.
   1. Add some new cert sorter tests with mocked status from the server. A
   small test utility class to simulate the server JSON will be useful for
   this.
   1. Any other tests that are leveraging cert sorter will probably need
   updating. Utility may be useful for this. This may replace some mocked
   entitlement cert code.
1. When a system is registered, but unable to reach the server:
   1. Whenever we fetch status from server, write a cache to disk.
      * Because this is just a full file write and not an append /
        modification, we should not need to worry about concurrent writes
        between say the GUI and the daemon running in the background. Last
        write will win, which is fine for our purposes, so no file locking is
        necessary.
   1. If we are unable to reach server but registered, display this prominently
   in the UI and indicate that we are unable to reach server temporarily.
   (pending mockups from mreid)
   1. If the cached compliantUntil time is greater than the current time, use
   the cached data to display product status normally instead of fetching from
   server.
   1. If the cached compliantUntil time is less than the current time, fall
   back to showing no status for products as per the disconnected use case, as
   we know we're showing inaccurate data.

---
title: Bugzila process
---
{% include toc.md %}

## Bugzilla process

 * A developer picks a bug in the order of priority and severity, and:
   * "takes" it ( `assigns` it to one's self )
   * Checks if the bug is dev-ack-ed appropriately
 * Commit messages must be of the format "BUGID: Description"
 * Once the developer is done working and has submitted a pull request for the same, the developer adds a github tracker on the bug to link the pull request ( format: candlepin/subscritpion-manager/pull/<PR_NUMBER> ).
 * If the release split[1] has already happened:
   * After the pull request is merged to master, the author of the pull request changes the state of the bug to `POST`. The release nanny will change the state to `MODIFIED` after cherry-picking your commits.
   * else, after the pull request is merged to master, the author of the pull request changes the state of the bug to `MODIFIED`.
 * After a brew build has been created and tagged as a rhel-X-candidate, the release nanny will add the bug to the appropriate errata and it will automatically be flipped to `ON_QA`.
 * After a bug has been `VERIFIED`, the release nanny updates the fixed-in-version field of the bug. ( to be automated soon )

[1] Release split: the moment when we cut a release branch off of master, after which we would need to start cherry-picking release candidates.


---
title: Bugzilla process
---
{% include toc.md %}

## Bugzilla process

 * A developer picks a bug in the order of priority and severity, and:
   * changes the state of the bug to `ASSIGNED`
   * "takes" it ( `assigns` it to one's self )
   * Checks if the bug is dev-ack-ed appropriately
 * Commit messages must be of the format "BUGID: Description"
 * Once the developer is done working and has submitted a pull request for the same:
   * The developer adds a github tracker on the bug to link the pull request ( format: candlepin/candlepin/pull/PR_NUMBER ).
   * The developer changes the state of the bug to `POST`
 * Before the reviewer starts to review the pull request, the reviewer assigns the pull request to self, and adds the `Needs Second Review` label if necessary.
 * After the pull request is merged to master,
   * the reviewer deletes the branch used for the PR.
   * the reviewer changes the state of the bug to `MODIFIED`.
   * the author of the pull request deletes the branch used for the PR if the reviewer missed it.
 * After a brew build has been created and tagged as a rhel-X-candidate, the release nanny will add the bug to the appropriate errata and it will automatically be flipped to `ON_QA`.
 * After a bug has been `VERIFIED`, the release nanny updates the fixed-in-version field of the bug. ( to be automated soon )

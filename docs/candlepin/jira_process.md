---
title: Jira process
---
{% include toc.md %}

# Jira process

 * A developer picks a [CANDLEPIN jira issue](https://issues.redhat.com/projects/CANDLEPIN/issues) that is in the `TODO` state, and:
   * changes the state of the issue to `IN PROGRESS`.
   * assigns it to one's self.
   * changes the state of linked the downstream issue (SAT jira, if any) to `IN PROGRESS`.
* All pull requests against a jira issue must have a commit message of the format "CANDLEPIN-1234: Description"
 * Once the developer is done working and has submitted a pull request for the same, the developer changes the state of the issue to `REVIEW`
 * Before the reviewer starts to review the pull request, the reviewer assigns the pull request to self, and adds the `Needs Second Review` label if necessary.
 * After the pull request is merged to the target branch,
   * the reviewer deletes the branch used for the PR.
   * the reviewer changes the state of the jira card to `DONE`.
   * the author of the pull request deletes the branch used for the PR if the reviewer missed it.
 * Once the candlepin release job is done, the jira should have automatically:
   * changed its state to `CLOSED` if it wasn't already
   * added the candlepin RPM version to the `Fixed in Build` field
   * changed the state of the related SAT jira (if any) to `RELEASE PENDING - UPSTREAM`.

## Security process

For unembargoed/public issues:

1. The jira issue can be picked up and worked as usual.
2. Email secalert@redhat.com (Red Hat Product Security), providing all relevant details and requesting a CVE identifier (if not done under embargo already). Expect a response within 48 working hours.
3. On receiving a CVE identifier, prefix the jira issue title with the CVE identifier.

For embargoed issues, handle in a similar way with these exceptions:

1. Take extreme care to make no public comments, emails, pull requests or IRC conversations on the subject. Ensure anybody working on the issue follows the same.
2. Email secalert@redhat.com (Red Hat Product Security), providing all relevant details and requesting a CVE identifier. Expect a response within 48 working hours.
  * Use GPG-encrypted email with the key 0xDCE3823597F5EAC4 (77E7 9ABE 9367 3533 ED09 EBE2 DCE3 8235 97F5 EAC4)
  * Mention whether or not the CVE potentially affects a Red Hat Product (RHEL or Satellite), so that ProdSec can create a respective jira against it.
3. Decide a suitable unembargo date (often ~2 weeks) when it would also be suitable to make a release of Candlepin.
4. Attach proposed patches to the jira issue, review in comments preferably. Don't use private comments.
5. On unembargo, submit the patch as a pull request and/or merge if tests are green.
6. Have the release manager of the current stable branch(es) make a patch release.

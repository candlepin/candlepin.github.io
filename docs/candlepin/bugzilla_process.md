---
title: Bugzilla process
---
{% include toc.md %}

# Bugzilla process

 * A developer picks a bug in the order of priority and severity, and:
   * changes the state of the bug to `ASSIGNED`
   * "takes" it ( `assigns` it to one's self )
* All pull requests against a bug filed in bugzilla must have a commit message of the format "BUGID: Description"
 * Once the developer is done working and has submitted a pull request for the same, the developer adds a github tracker on the bug to link the pull request ( format: candlepin/candlepin/pull/PR_NUMBER ), and changes the state of the bug to `POST`
 * Before the reviewer starts to review the pull request, the reviewer assigns the pull request to self, and adds the `Needs Second Review` label if necessary.
 * After the pull request is merged to main,
   * the reviewer deletes the branch used for the PR.
   * the reviewer changes the state of the Candlepin project bug to `MODIFIED`.
   * the reviewer changes the state of the downstream bug ( if any ) to `POST`.
   * the author of the pull request deletes the branch used for the PR if the reviewer missed it.
 * After a brew build has been created, the release nanny:
   * Changes the state to `CLOSED` - currentrelease
   * Adds the RPM build version to the fixed-in-version field of the bug.

## Security process

For unembargoed/public issues:

1. The Bugzilla bug can be picked up and worked as usual.
2. Email secalert@redhat.com (Red Hat Product Security), providing all relevant details and requesting a CVE identifier (if not done under embargo already). Expect a response within 48 working hours.
3. On receiving a CVE identifier, prefix the Bugzilla bug title with the CVE identifier.

For embargoed issues, handle in a similar way with these exceptions:

1. Take extreme care to make no public comments, emails, pull requests or IRC conversations on the subject. Ensure anybody working on the issue follows the same.
2. Email secalert@redhat.com (Red Hat Product Security), providing all relevant details and requesting a CVE identifier. Expect a response within 48 working hours.
  * Use GPG-encrypted email with the key 0xDCE3823597F5EAC4 (77E7 9ABE 9367 3533 ED09 EBE2 DCE3 8235 97F5 EAC4)
3. Decide a suitable unembargo date (often ~2 weeks) when it would also be suitable to make a release of Candlepin.
4. File a Bugzilla bug against an appropriate Red Hat product (RHEL or Satellite 6), but ensure "Security Sensitive Bug" is checked which makes the bug visible to security team members and Bugzilla administrators. Make sure you add the Security keyword on the bug.
5. Attach proposed patches to the Bugzilla bug, review in comments preferably. Don't use private comments.
6. On unembargo, submit the patch as a pull request and/or merge if tests are green.
7. Have the release manager of the current stable branch(es) make a patch release.

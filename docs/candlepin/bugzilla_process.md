---
title: Bugzila process
---
{% include toc.md %}

# Bugzilla process

 * A developer picks a bug in the order of priority and severity, and "takes" it ( `assigns` it to one's self )
 * All pull requests against a bug filed in bugzilla must have a commit message of the format "BUGID: Description"
 * Once the developer is done working and has submitted a pull request for the same, the developer adds a private comment[1] on the bug with a link to the pull request, and changes the state of the bug to `POST`
 * Before the reviewer starts to review the pull request, the reviewer assigns the pull request to self, and adds the `Needs Second Review` label if necessary.
 * After the pull request is merged to master,
   * the reviewer deletes the branch used for the PR.
   * the author of the pull request changes the state of the upstream bug to `MODIFIED`.
   * the author of the pull request changes the state of the downstream bug ( if any ) to `POST`.
   * the author of the pull request deletes the branch used for the PR if the reviewer missed it.
 * After a brew build has been created, the release nanny:
   * Changes the state to `CLOSED` - currentrelease
   * Adds the RPM build version to the fixed-in-version field of the bug.

[1] Example format for linging PR:

```
    Pull Request:  
    https://github.com/candlepin/candlepin/pull/32
```


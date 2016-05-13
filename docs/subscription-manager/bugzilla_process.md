---
title: Bugzila process
---
{% include toc.md %}

## Bugzilla process

 * A developer picks a bug in the order of priority and severity, and:
   * "takes" it ( `assigns` it to one's self )
   * Checks if the bug is dev-ack-ed appropriately
 * Commit messages must be of the format "<BUGID>: Description"
 * Once the developer is done working and has submitted a pull request for the same, the developer adds a private comment[2] on the bug with a link to the pull request and the commit hashes.
 * If the release split[1] has already happened:
   * After the pull request is merged to master, the author of the pull request changes the state of the bug to `POST`. The release nanny will change the state to `MODIFIED` after cherry-picking your commits.
   * else, after the pull request is merged to master, the author of the pull request changes the state of the bug to `MODIFIED`.
 * After a brew build has been created and tagged as a rhel-X-candidate, the release nanny will add the bug to the appropriate errata and it will automatically be flipped to `ON_QA`.
 * After a bug has been `VERIFIED`, the release nanny updates the fixed-in-version field of the bug. ( to be automated soon )

[1] Release split: the moment when we cut a release branch off of master, after which we would need to start cherry-picking release candidates.

[2] Example format for linking PR and commits:

```
    Pull Request:  
    https://github.com/candlepin/subscription-manager/pull/32  
    Commits:  
    6454cc467f9f53a1089cbd1f3f3833b68e455c88  
    f40eca25a1cf3487770fe6b85d6e3de0ffe80d54  
    78feda24871dc1bef3b97d72d29d952321638bc3  
    6b029357be517fbe4a85748120a6f23826316253  
    5854f99a869cf578af39f4c0fdda3a25bbf7fa4b
```


---
title: What to look for in a Code Review
---
{% include toc.md %}

# What to look for in a Code Review
## Overview
In doing a code review, you should make sure that:
 - Code is well-designed.
 - Functionality is good for the users of the code.
 - API changes are sensible and required by the task.
 - Parallel programming is done safely.
 - Code isn’t more complex than it needs to be.
 - Code has appropriate tests.
 - Tests are well-designed.
 - Naming is clear and descriptive.
 - Comments are clear and useful, and mostly explain why instead of what.
 - Code is appropriately documented.
 - The code conforms to our style guides.

## Design
One of the most important things to consider in a review is the overall design. Do the interactions of various pieces of code in the PR make sense? Is there a better way to do this? One thing to note is that the review might be too late for a design feedback and can lead to waste of effort if significant design changes are needed. Author should try to get design feedback early to minimize such issues.

Even with the early feedback it sometimes happens that design is faulty/incomplete. Do not accept a PR just for the sake of moving the card to done because you think 'it's too late for redesign'. Always flag any doubts about it!

## Functionality
Is the PR solving the right problem? Is what the developer intended good for the users of this code? Where “users” are both end-users (when they are affected by the change) and developers (who will have to use this code in the future). Such as breaking changes in the API. Do not accept a PR if you think it's not solving the right problem. Voice any doubts even if (especially if) this means the task should go back to the Use Cases / discussion with Product Management.

A specific type of ‘user’ we care about in Candlepin is the stakeholders of different systems/components that interact with Candlepin. So when you review changes that either a) change the API, or b) change the behaviour of functionality (as opposed to internal-only changes), you should always ask yourself ‘how will this affect subman/virt-who/Katello/Adapters/RHSM API?’.

The review should start with a task definition(Jira, BZ) in order to know what issue this PR is trying to solve. Don’t be afraid to get familiar with the original code first. Reviewing changes for unfamiliar parts of the codebase can be challenging. Do spend as much time as you need to understand the existing code & the new code. It might take longer, but this has multiple medium/long-term benefits: The developer becomes more familiar with the system, and therefore can better validate design/functionality/other requirements in future PR reviews.

Another time when it’s particularly important to think about functionality during a code review is if there is some sort of parallel programming going on in the PR that could theoretically cause deadlocks or race conditions. These sorts of issues are very hard to detect by just running the code and usually need somebody to think through them carefully to be sure that problems aren’t being introduced.

## Maintainability
Is the code more complex than it should be? Complexity here can mean multiple things. Code should be readable with well named pieces. Are they descriptive enough to show their intent? Or are they unnecessarily verbose and make code hard to follow. Complexity can also mean that developers are likely to introduce bugs when they try to call or modify this code.

## Testing
Code should be covered by unit, integration, or end-to-end tests as appropriate for the change.
Make sure that the tests in the PR are correct, sensible, and useful. Tests do not test themselves, and we rarely write tests for our tests. A human must ensure that tests are valid.

Will the tests actually fail when the code is broken? If the code changes beneath them, will they start producing false positives? Does each test make simple and useful assertions?

Remember that tests are also code that has to be maintained. Don’t accept complexity in tests just because they aren’t part of the main binary.

## Performance
Does this task have performance requirements? Are there any performance pitfalls that are avoidable? Could the operation be performed in a bulk?

Does the code use locks to access shared resources? Could this result in poor performance or deadlocks? Locks are a performance killer and very hard to reason about in a multi-threaded environment. Consider patterns like; having only a single thread that writes/changes values while all other threads are free to read; or using lock free algorithms.

Is there something in the code which could lead to a memory leak? In Java, some common causes can be: mutable static fields, using ThreadLocal and using a ClassLoader.

## Documentation
If a PR changes how users build, test, interact with, or release code, check to see that it also updates associated documentation, including READMEs or candlepinproject. If the PR deletes or deprecates code, consider whether the documentation should also be deleted.

If a PR changes the behaviour and/or signatures of Classes/Methods, check that the javadoc comments also change to reflect those changes.

## Comments
Did the developer write clear comments in understandable English? Are all of the comments actually necessary? Usually comments are useful when they explain why some code exists, and should not be explaining what some code is doing. If the code isn’t clear enough to explain itself, then the code should be improved. There are some exceptions (regular expressions and complex algorithms often benefit greatly from comments that explain what they’re doing, for example) but mostly comments are for information that the code itself can’t possibly contain, like the reasoning behind a decision.

It can also be helpful to look at comments that were there before this PR. Maybe there is a TODO that can be removed now, a comment advising against this change being made, etc.
Note that comments are different from documentation of classes, modules, or functions, which should instead express the purpose of a piece of code, how it should be used, and how it behaves when used.

## Style
While it is important for the code to consistently follow the style guide agreed upon by the team. It should preferably be checked by a formatting tool such as Checkstyle. Code style violations should be fixed there to prevent them in the future.

## Candlepin specific
We can add a few hints for review of some of the specific areas of Candlepin.

### Curators
 - Queries should not affect unrelated orgs

### Rules
 - Version should be incremented when rules are updated

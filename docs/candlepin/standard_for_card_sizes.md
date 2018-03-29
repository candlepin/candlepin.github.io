---
title: Standard for Card Sizes
---
{% include toc.md %}

# Standard for Card Sizes

Each card should have an assigned card size with estimation of its complexity. It helps with planning and evaluation of a sprint. Sizes of cards are usually estimated during the meeting called “Backlog Grooming” by all members of team, but the size of a new card can be also estimated by one member of team, when this card is created during the sprint (e.g. card is related to some bug fix with high priority and severity).

This document should provide description of issue complexity for each corresponding card size. This document is intended for new members of the team. We are not providing any time scope for card size, because we are not willing to put developers under pressure and it is also hard to estimate, because relates issue is not solved only by one developer (e.g. PR requires somebody else to do PR review). Any estimation could be also wrong and issue can become more or less complicated than anybody can estimate.

## Size 1

**Description:** This task is something really very simple to do, but it has to be done by a developer from the Candlepin team.

**Examples:**

* One line bug fix without any need of adding more unit tests.
* Adding simple note to documentation.

## Size 3

**Description:** Corresponding task is usually something simple to solve, but it requires more effort to solve than size 1.

**Examples:**

* Bug fix of bug report from Bugzilla marked as “EasyFix” keyword (developer has to read BZ bug report, reproduce it, etc.)
* Write documentation about a new simple feature

## Size 5

**Description:** Some issue that is possible to solve during half of one day.

**Examples:**

* Bug fix of “standard” bug report from Bugzilla. Keep in mind that bug fixing can sometimes require more effort due to refactoring, complicated reproduction of bug, etc.
* Implementation of simple RFE

## Size 8

**Description:** Most common size of card. This is somewhere between simple and complicated.

**Examples:**

* Complicated bug fixing
* Implementation of RFE
* Implementation of new feature

## Size 13

**Description:** Big issue requiring a lot of effort, experience and knowledge about subscriptions, entitlements, etc. It can also be more simple issue requiring studying new technology.

**Examples:**

* Implementation of new complex feature, RFE
* Refactoring of bigger part of code

## Size 20

**Description:** This is the maximum allowed size of card that is possible to solve as a single sprint task, but if possible, we should consider splitting into more cards (e.g. investigation of problem and solving the problem). Use this size when it is not possible to split it into more cards.

**Examples:**

* Complex refactoring of code that could not be split into more tasks. 

## Size 40
**Description:** when a card is estimated with this size, then such card must be split into more cards.

## Size 100

**Description:** this is the similar as for previous case, but it is even worse and it should lead to some EPIC project. It probably requires more planning.

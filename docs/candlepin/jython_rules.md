---
title: Jython Rules
---
{% include toc.md %}

# Converting our Rules Engine from Javascript to Python

Writing our rules in python would make it easier to share the logic with
subscription manager (and some people prefer python over javascript). It'd be
better to do this sooner rather than later, so here is a rough outline for
converting candlepin to using python for the rules instead of javascript.

This doesn't consider how we'd get some subset of the rules to the client; we
can tackle that later.

I'm 99% sure jython will meet our needs. Javascript gave us one headache
before, where it had to recompile the rules for each execution (which was
slow). We got around this by moving from the javax scripting API to rhino,
which exposed an api to precompile javascript. We put this precompiling
operation behind a mutex, letting us use the compiled rules for all threads,
and only compiling once at bootup, or whenver the rules are updated. We further
had to toggle a flag to let the jvm global rules read thread local variables,
but it all worked out. As far as I can tell, the 3 concepts here (compiler,
global compiled code, thread local variable namespaces) all map 1 to 1 into
jython classes.

## Plan for Conversion
Only classes under the org.fedoraproject.candlepin.policy.js package reference org.mozilla.javascript. 3 of those classes use it for RhinoException:

* ComplianceRules
* EntitlementRules
* JsExportRules

In nearly all cases they're catching it from jsRules.invokeMethod, and then
simply wrapping it in a RuleExecutionException. Lets teach jsRules.invokeMethod
to do that itself. That leaves us then with only two classes dealing with
javascript:
 
* JsRulesProvider
* JsRules

Given the previously mentioned 1 to 1 mapping, conversion of these two classes
should actually be pretty easy. We only need to take care that similar
exceptions are thrown, and that we catch them properly.

We should probably change the package name to something like
org.fedoraproject.candlepin.policy.script or something, too.

JsRulesProvider is a guice provider that handles precompiling the rules, and
setting up thread local contexts. 

## Javascript to Python conversion
For starters we should just do a straight port of the code, which should be easy enough.

## Where to now?
After this, we'd have our same rules setup, only in python instead of javascript. Some ideas for the future:

* Replace our ReadOnly\* classes with data classes that live in the python rules
  itself. either populate these in the java code before calling the rules, or
  have the rules populate them from json data, this way on the client side, we
  can use the same set of data classes (TODO: investigate effects on how much
  we have to load from the db, memory usage, etc)
* Seperate the rules out into server specific and client/server modules, either
  in seperate files, or seperate classes, etc.
* Provide a way for the client to slurp down the rules and execute them in a
  safe context, for entitlement validity checking and whatnot.

# JUnit 5 in Candlepin

By Alex Wood <!-- .element class="caption" -->

Copyright 2019 <!-- .element class="caption" -->

Licensed Under [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)

<!-- .element class="caption" -->

----
# Overview

- Preliminary
- New Annotations
- No Rules!
- Odds & Ends
- JUnit 4 Support
- Mockito 2
* Questions


----
# Preliminary

* JUnit 5 is much more granular.  It has multiple artifacts under
  "org.junit.jupiter"
* Buildr does not work with JUnit 5.
  * The Buildr
    [test](https://github.com/apache/buildr/blob/master/lib/buildr/java/tests.rb#L195)
    class uses "org.junit:junit".
* JUnit 5 went in after Gradle so no Buildr should be okay
* `mvn test -Dmaven.test.skip=false` is a fail-safe

----
# New Annotations

* `@Before` and `@After` are now `@BeforeEach` and `@AfterEach`
* `@BeforeClass` and `@AfterClass` are `@BeforeAll` and `@AfterAll`
* `@RunWith` is now `@ExtendWith` and you can have multiple extensions
* `@Ignore` is now `@Disabled`
* `@Test` does not accept an `expected` argument

----
# No Rules

* The `@Rule` annotation is no more
* We used it in 3 ways:
  * `CandlepinLiquibaseResource` now
    `@ExtendWith(LiquibaseExtension.class)`
  * `TemporaryFolder` now `@TempDir` on a field or a test method parameter
     ```
     @Test
     void testSomething(@TempDir Path t) {
     ...
     ```
  * `ExpectedException`

----
# No Rules

* Using `@Test(expected = ...)` often lead to false negatives
  ```
  foo.doSomethingNormal() // Exception thrown unexpectedly here
  foo.doSomethingCausingAnError() // Never gets tested!
  ```
* Exception handling is now handled much more gracefully.

  ```
  IllegalArgumentException e = assertThrows(IllegalArgumentException.class, () -> foo.doSomething());
  assertEquals("An error message", e.getMessage());
  ```

----
# Odds & Ends

* Parameterized testing is now built-in
* Semantics for parameterized tests:
  * Specify a list of primitives going in
  * Specify a callback that will feed a `Stream` into the test runner
* `public` is no longer required on tests or test methods, but I left it in
* Assertion parameter order swapped when using a custom message
  ```
  assertEquals("Line number count", lineCount, lines.size()); // JUnit 4
  assertEquals(lineCount, lines.size(), "Line number count"); // JUnit 5
  assertEquals(lineCount, lines.size()); // JUnit 4 AND 5
  ```
----
# Odds & Ends

* The number of assertions has been trimmed down.  `assertThat` is gone,
  for example
  * Use `org.hamcrest.MatcherAssert` and other Hamcrest classes to
    replicate functionality

----
# JUnit 4 Support

* We can still run JUnit 4 tests using the "junit-vintage-engine" but
  that's just a stop-gap.
* Write all new tests in JUnit 5 and convert to JUnit 5 when you make
  substantial changes to an existing JUnit 4 test.

----
# Mockito 2

* Part of the upgrade included moving to the stricter Mockito 2
* `any(...)` no longer matches null!  Use `nullable(...)`!
* Unnecessary mocking results in an error unless you use
  `@MockitoSettings(strictness = Strictness.LENIENT)`

----
Questions?

---
layout: default
categories: developers
title: Coding Conventions
---
{% include toc.md %}

# Java Coding Conventions
This document contains the standard conventions that should be followed when
writing Java code for the Candlepin project.  Everything not specifically
addressed by this document should follow the official [Code Conventions for the
Java Programming Language](http://www.oracle.com/technetwork/java/javase/documentation/codeconvtoc-136057.html)

Conventions specific to Candlepin have been primarily drawn from the
conventions imposed by
[Spacewalk](https://fedorahosted.org/spacewalk/wiki/JavaCodingConventions), or
have been invented to accommodate matters of internal style and practicality.
To help people conform to the document conventions, we have integrated
[checkstyle](http://checkstyle.sourceforge.net/) into our build tree.

The checkstyle configuration file, `buildconf/checkstyle.xml`, is our
definitive style guide source.  The conventions here should be putting
those conventions into english and for things checkstyle can't check.
[Configuration Checkstyle](checkstyle.html)

## Brackets
All left brackets should be the end of the line and all right brackets should be alone on the line.

```java
// Correct
public class SomeClass {
    public void someMethod() {
        if (...) {
            try {
                // do something
            }
            catch (IOException ioe) {
                // handle exception
            }
            catch (SecurityException se) {
                // handle exception
            }
        }
        else if (...) {
            // do something else.
        }
    }
}
```
{:.alert-good}

```java
// INCORRECT
public class SomeIncorrectClass {
    public void someMethod()
    {
        if (...)
        {
            try {
                // do something
            } catch (IOException ioe) {
                // handle exception
            } catch (SecurityException se) {
                // handle exception
            }
        } else if (...) {
            // do something else.
        }
    }
}
```
{:.alert-bad}

Brackets are mandatory even for single line statements!

```java
// Correct
if (expression) {
    // some code
}
```
{:.alert-good}

```java
// INCORRECT
if (expression)
    // some code
```
{:.alert-bad}

## EOL
All .java source files should use the Unix text file format 
(e.g. Unix-style EOLs).  Any platform specific files should have a file format
appropriate for its target platform (i.e. a .bat file should use a DOS
text file format).  

## Directories
Files and Directories should be named such that no case-insensitive
duplications occur (i.e.  don't create a directory named "build" in a directory
where a file named "BUILD" exists).

## Naming
The following conventions are meant to further refine the conventions described by
[section 9](http://www.oracle.com/technetwork/java/javase/documentation/codeconventions-135099.html#367)
of the Java coding conventions.

### Packages 
All in house packages should be a subpackage of "org.candlepin"

package org.candlepin.util
{:.alert .alert-example}

### Classes
Use of '\_' in classnames should be avoided but is not strictly 
prohibited.  An appropriate use of '\_' in a class name would be
to separate multiple back-to-back acronyms (after seriously considering
whether the chosen classname is appropriate).

class SSL_RPCSocket
{:.alert .alert-example}

### Interfaces
Interface names should follow the conventions for class names. They should
**NOT** be prefixed with an I such as IUser.

interface RPCService
{:.alert .alert-example}

### Methods
The use of '\_' should be avoided in method names.

### Variables
The use of '\_' should be avoided in variable names.

### Constants
The names of constants should not include a leading '\_'.

## Whitespace
* Tab characters are not allowed in source code.
* A space should appear after the right parenthesis for typecasts

  ```java
  // Correct
  String myString = (String) list.get(1);
  ```
  {:.alert-good}
  
  ```java
  // INCORRECT
  String myString = (String)list.get(1);
  ```
  {:.alert-bad}

* Whitespace should appear between the following tokens and their subsequent
  open parenthesis: assert, catch, for, if, synchronized, switch, while (in
  accordance with [section 8.2](http://www.oracle.com/technetwork/java/javase/documentation/codeconventions-141388.html#682)
  of the Java coding conventions.

  ```java
  // Correct
  while (this == that) {
      ...
  }
  ```
  {:.alert-good}
  
  ```java
  // INCORRECT
  while(this == that) {
       ^
  }
  ```
  {:.alert-bad}

* The preference is to use a single space rather than a tab to separate the
  type and the identifier for variable declarations.

  ```java
  // Correct
  BigDecimal myNumber
  int level;
  ```
  {:.alert-good}
  
  ```java
  // INCORRECT
  BigDecimal   myNumber;
  int          level;
  ```
  {:.alert-bad}

## Indentations
Indentation should be four spaces -- **not tabs**.

For emacs users, the following will produce four space indents rather than tabs:

```scheme
(setq-default tab-width 4 indent-tabs-mode nil)
```

Vim users can add the following to their .vimrc

```vim
set ts=4
set expandtab
```

## Line length
Avoid lines longer than 92 characters.  This is contrary to [section 4.1](http://www.oracle.com/technetwork/java/javase/documentation/codeconventions-136091.html#313)
of the Java coding conventions. While we allow 92 characters, many developers 
strive to keep to the 80 character limit.

## Comments
Javadoc comments **SHOULD** exist on all non-private methods and fields.
Comments on methods should indicate any assumptions made about the method's
parameters. Also, if you are working on existing code and the code is missing
javadoc comments, then you should add comments or call it to the attention of
an appropriate developer. Checkstyle looks for "{@inheritDoc}" to determine
that the method inherits its comments from a parent class.

Methods or classes that have been incompletely implemented or for which the
developer has specific ideas for improvement should have a @todo javadoc
comment indicating what work remains, followed by the developer's account
name and a date. Elaborate with further comments interspersed in the code as
necessary.

```java
/**
 * ...
 * @todo Figure out how best to handle IOException here (kdykeman - 2003/10/08)
 */
```

Please refer to the [Javadoc home page](http://www.oracle.com/technetwork/java/javase/documentation/javadoc-137458.html)
if you are unfamiliar with Javadoc.

Note that while javadocs are encouraged for test classes where
appropriate, checkstyle does not require javadoc comments for test
classes.

## License
The following license message should be placed at the top of each
Spacewalk generated source file:

```java
/**
 * Copyright (c) 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 * 
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation. 
 */
```

The way the license file was written, checkstyle expects a space after the \*
separating the second and third paragraphs as well as a space after the period
at the end of the last line.
{:.alert-notice}

## Qualified imports
All import statements should contain the full class name of classes to 
import and should not use the "\*" notation (Eclipse can help do this quickly):
An example:

```java
// Correct
import java.net.HttpURLConnection;
import java.util.Date;
```
{:.alert-good}

```java
// INCORRECT
import java.util.*;
import java.net.*;
```
{:.alert-bad}

## Logging
Do not use System.out or System.err to log; instead, use the 
[logging API](logging.html).

Care should be taken to log messages at an appropriate level
for the information they present (keeping in mind that the default log
level is INFO).

trace
: designates finest-grained informational events that highlight the
stepwise progress of the application.

  Entering method foo
  {:.alert .alert-example}

debug
: designates fine-grained informational events that are most useful
for debugging an application.

  Item 'bar' removed from cache.
  {:.alert .alert-example}

info
: designates informational messages that highlight the progress of
the application at coarse-grained level.

  The service started successfully
  {:.alert .alert-example}

warn
: designates potentially harmful situations.

  Property value not set, using default value
  {:.alert .alert-example}

error
: designates error events (including potentially fatal ones)

  SSL certificate not found on startup.
  {:.alert .alert-example}

## Hidden Fields
Parameter names for a method should not shadow fields defined in the same
class.  Shadowing a field leads to situations that can result in
inadvertently using the wrong variable.  Below is a contrived example of
shadowing and the problems that it can introduce:

```java
public class Foo {
    private String myString = "bar";

    public Foo(String myString) {
        this.myString = myString;
        myString = myString + "baz";  // Oops!
    }
}
```

## File and Method lengths
Any of the following conditions should be taken as indication that a
class/method should be refactored:
 
* Source files with a length greater than *2500* lines.
* Methods with a length greater than *150* lines.
* Methods taking more than *12* parameters.
    
## Exception handling
Avoid catching Throwable or Exception and catch specific exceptions instead.

If an exception is caught and rethrown as a different exception type, the new
exception should be constructed with the caught exception as the cause.  This
allows stack trace information for the original exception to be preserved.

If you catch an exception and decide not to rethrow it for whatever reason,
you should log it.  In particular, do not use the printStackTrace()
method because its output goes to stderr rather than to the logging system.

When logging an exception, invoke one of the logging methods taking two
parameters - a message and the exception.  SLF4J [will not](http://www.slf4j.org/faq.html#exception_message)
allow you to log a bare exception alone.  You must provide a String message.

The following is an example of how to properly log a "handled" exception:

```java
try {
    doSomethingRisky();
}
catch (RiskyException re) {
    log.error("risky failed", re);
}
```

---
title: Setting up IntelliJ IDEA
---
{% include toc.md %}

# Using IntelliJ IDEA
IntelliJ IDEA can be setup so that it already has the preferred code style,
import order, etc. for the Candlepin Project.  IDEA is slightly different than
Eclipse in that it understands nesting: in IDEA you can have an overall
*project* that is composed of multiple *modules*.

## Process
Before you begin, ensure you have the Candlepin git repository checked out,
Buildr working, and IntelliJ IDEA installed and registered.  I also recommend
running `buildr artifacts; buildr artifacts:sources` so that you will be able to
browse the source code of the libraries we use from within IDEA.

1. Begin by running `buildr idea`.  This task will take care of generating the
   assorted classpaths, module definitions, etc.
1. Start IDEA.  On the "Welcome to IntelliJ IDEA" dialog, select _Open_ since we
   already have the project files generated.
1. Navigate to your checkout and select the `candlepin.ipr` file in the checkout
   directory.
1. Immediately, open the Project Structure dialog (_File -> Project Structure_).
   I'm not certain how Buildr constructs the value for Project SDK setting, but
   if it is highlighted red you will need to correct it.  Select `New...` next
   to the incorrect Project SDK, then select JVM and then navigate to your
   `$JAVA_HOME` (`/usr/lib/jvm/java-1.8.0-openjdk` for me).
1. Go to the _Modules_ branch of the Project Settings tree.
1. For each module, go to the _Dependencies_ tab and select "Project SDK" from
   the _Module SDK_ combo box.

## Settings Import
If you wish, you can import some existing settings that I have exported.
Unfortunately, IDEA doesn't let you really pick and choose the settings you want
to export, so the exported settings include both the useful (e.g. the team's
accepted import order) and the personal (e.g. my color scheme).

If you do want to import these settings just to get a jump-start, here's what
you should do.

1. Open the _Settings_ dialog found under _File -> Settings_.
1. Go to the _Tools_ branch and expand it.
1. Go to the _Settings Repository_ item.
1. Next to "Read-only Sources" click the green plus sign and enter
   `https://github.com/candlepin/intellij` in the dialog.
1. Now you will be able to read from the settings repository but not write to
   it.  Once those settings have been imported, you will likely want to just
   uncheck the box next to the settings repository you just created so that
   your personal settings aren't overwritten.  (I am not sure what order
   IntelliJ resolves conflicts in).

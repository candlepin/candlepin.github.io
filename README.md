[![Build Status](https://travis-ci.org/candlepin/candlepinproject.org.png?branch=master)](https://travis-ci.org/candlepin/candlepinproject.org)

# Getting Started
1. `yum install python-pygments gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel plantuml graphviz`

1. Install [RVM](http://rvm.io). I know RVM can be a pain when you first start
   using it, but OpenShift uses Ruby 2.0.0 which is several minor releases
   behind the current bleeding edge.  Note: do **NOT** install RVM as root.

   First you must configure your terminal emulator to act as a login shell.  In
   gnome-terminal, go to "Edit -> Profile Preferences -> Title and Command".
   Check the box reading "Run command as login shell."  In xfce4-terminal, go to
   "Edit -> Preferences" and check the "Run command as login shell" box.  See
   <https://rvm.io/integration/gnome-terminal>

   Start a new terminal and run the following:

   ```
   $ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
   $ curl -sSL https://get.rvm.io | bash -s stable --ruby=ruby-2.0.0-p643 --ruby=ruby-2.2.1
   $ rvm --default use ruby-2.2.1
   ```

   With these settings, RVM will use Ruby 2.2.1 as a default.  However, when you
   `cd` to the website directory RVM will detect the `.ruby-version` and
   `.ruby-gemset` files and switch to Ruby 2.0.0 and the candlepinproject.org
   gemset.  The documentation for RVM is extensive so don't be afraid to read
   it.
1. Go into your checkout directory and run `bundle install`
1. (Optional) Install and configure Travis.  This will allow you to interact
   with the continuous integration environment from the command line.  Note that
   you have to do this separately because there is a gem conflict with the
   site's bundle.

   ```
   gem install travis
   travis login --org
   ```
1. Render the site with `jekyll serve --watch`.  (See Advanced Workflow section
   for tips on getting real time previews of your updates).
1. Make changes and save.  If you wish to create a news item, run `jekyll post
   "My Title"`.  That command calls out to a plugin that will create a file with
   the correct name and format and open your editor as defined by VISUAL or
   EDITOR.  You can use a different editor with the `--editor` option.
1. Jekyll will automatically render your changes.

# Advanced Workflow
1. *Optional*: Open port 4000 in your firewall so others can see your local site

    ```
    $ firewall-cmd --add-port=4000/tcp --permanent
    ```
2. If you wish to see real time previews of your updates (i.e. if you don't
   want to hit the refresh button all the time), then you can use
   `jekyll liveserve`.  This command calls out to a plugin I wrote named
   [Hawkins](https://github.com/awood/hawkins) that integrates the
   [LiveReload protocol](http://feedback.livereload.com/knowledgebase/articles/86174-livereload-protocol)
   with some hooks that Jekyll provides.

   You should see a notice that Jekyll is serving on port 4000 and that
   LiveReload is listening on port 35729.  Go to http://localhost:4000 and visit
   a page.  When you edit that page's source Markdown file and save, Jekyll will
   see the file modification and trigger a site build.  LiveReload will then
   refresh your browser for you if your browser is connected.  Sometimes it is a
   bit tricky to get the browser to make the initial WebSockets connection.  You
   may have to refresh or shift-refresh a few times.  You're connected when you
   see the "Browser connected" message in the Jekyll output.

3. **Extreme ProTip**: Unfortunately, Jekyll is a bit simplistic in how it
   regenerates sites.  It regenerates everything instead of just what it needs
   to.  The Jekyll team has recognized this deficiency and has added an
   experimental option `--incremental`/`-I` that attempts to only regenerate the
   pages that actually changed.  In my experience, it works well, so use it!

# Navigation
In order for a page to appear on the left-hand navigation column, it needs to be
listed in `_data/toc.yaml`.  Use the basename of the page (e.g. 'foo' if the
page is 'foo.md') and insert it into YAML heirarchy under the appropriate
project and appropriate topic.  If you forget to include your page in the
heirarchy, Jekyll will issue a warning when it is rendering the site.

# Deployment
1. Submit your changes as a PR.  The Travis continuous integration hook will run
   automatically.  If the build fails correct it.  Otherwise, when the PR is
   merged into master, Travis will run and deploy the site.
1. Travis configuration is in `.travis.yml` and in a few files located in the
   `_travis` directory.
1. If you need to work more extensively with Travis, I recommend installing
   the `travis` gem.  See <https://github.com/travis-ci/travis.rb#readme>.

# Syntax Highlighting
Syntax highlighting is provided by [Pygments](http://pygments.org) (more
specifically by Pygments.rb -- a Ruby binding to Pygments).  Set the
highlighting on a code block by providing a lexer name after the three backticks
that indicate the beginning of a code block.

The list of lexers is available at <http://pygments.org/docs/lexers/>, but in
general they are named like you would expect.  The most common ones we use are

* java
* ruby
* python
* console (a Bash console session)
* json
* properties (Java Properties format)
* bash (a Bash script)
* sql
* ini (for Python conf files)
* yaml

A special note about the console lexer: if the line is a command, you must begin
with a "$", "#", or "%" otherwise the text will be treated as output.  E.g.

**Correct**

```console
$ ./subscription-manager
```

**INCORRECT**

```console
./subscription-manager
```

# Gotchas
* In Markdown, whitespace matters!  Specifically, when you're in a block (like a
  list element in a bulleted list) you need to make sure all sub-blocks have the
  same initial indentation.

**Correct**
<pre>
* Hello World looks like
  ```
  print "Hello World"
  ```
</pre>

**INCORRECT**
<pre>
* Hello World looks like
```
print "Hello World"
```
</pre>

* Be careful with internal links.  Preface them with {{ site.baseurl }} if they
  are in another directory.  See
  <http://jekyllrb.com/docs/github-pages/#project_page_url_structure>
* The URLs for all posts and pages contain a leading slash so there is no need
  to provide one.  E.g. Linking to a post would use {{ site.baseurl }}{{
  post.url }}

# Tips
* If you want to see an overview of an object in Liquid, filter it through the
  debug filter from `_plugins.` E.g. `{{ page | debug }}`
* To find code blocks missing a lexer, install pcre-tools and use the following
  `pcregrep -r -M -n '^$\n^```$' *`
* Vim associates '.md' files with Modula-2.  Add the following to your .vimrc to
  change the association:

  ```
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown
  ```

# Openshift Setup
To talk directly to the application running on Openshift, you need to first
associate your checkout with the application.  Go into your checkout directory
and perform the following.

1. `gem install rhc`
1. `rhc setup`
1. Configure `rhc` with application and namespace defaults.

   ```
   cat >> .git/config <<RHC
   [rhc]
       app-id = 56702a4789f5cfd04d000098
       app-name = website
       domain-name = candlepinproject
   RHC
   ```
1. `git add remote openshift
   ssh://56702a4789f5cfd04d000098@website-candlepinproject.rhcloud.com/~/git/website.git/`

You can now use the `rhc` tool in this directory without having to specify the
application all the time.  E.g. `rhc tail`.  Additionally, you can view the
Openshift git history.  Please do not push directly to the `openshift` remote.
Let Travis do that.

# Openshift Details
We require two extra gears for our application to run. Both gears are used to
provide diagram support using plantuml. The first is
openshift-graphviz-cartridge from
<https://github.com/puzzle/openshift-graphviz-cartridge>.  The second is
openshift-plantuml-cartridge from
<https://github.com/candlepin/openshift-plantuml-cartridge>.

Right now, we have the BUNDLE_WITHOUT environment variable set to "development"
to exclude gems that are in the development group in the Gemfile.  If you ever
need to change that then run the following in your Openshift app checkout.

```
$ rhc set-env BUNDLE_WITHOUT="development"
```

You can view the current custom environment variables with

```
$ rhc env list
```

# References
* We use RVM to manage Ruby versions and gemsets.  See
  <https://rvm.io/#docindex>
* Jekyll is the engine used to create the site.  There is very good
  documentation at <http://jekyllrb.com/docs/home/>
* We are using Kramdown as our Markdown renderer. There is a quick reference at
  <http://kramdown.gettalong.org/quickref.html> and a more complete syntax guide
  at <http://kramdown.gettalong.org/syntax.html>
* The CSS is written using Sass <http://sass-lang.org>.
* The JS and theming are courtesy of Bootstrap <http://getbootstrap.com/>
  although I did strip out some of the JS that we probably would not use like
  the carousel and modal dialog functions.

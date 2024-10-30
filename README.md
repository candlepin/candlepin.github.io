![Build Status](https://github.com/candlepin/candlepin.github.io/actions/workflows/deploy.yml/badge.svg?branch=main)

# Getting Started
## Container Development (Easy Mode)
1. Build the `Dockerfile` image.
   ```
   $ podman build -t candlepin/jekyll -f Dockerfile
   ```
1. Run the `candlepin/jekyll` image with the site source mounted into it. Image can be used to build the site or test it via serve.
   ```
   $ podman run -p 4000:4000 -v "$(pwd)":/site candlepin/jekyll serve --livereload --force_polling -H "0.0.0.0" -P 4000
   ```
1. You should only need to rebuild the images if something in the site software
   stack changes: e.g. new gems.

## Local Development (Hard Mode)
1. `yum install python-pygments gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel plantuml graphviz`

1. Make sure you have python 3 installed

1. Install [RVM](http://rvm.io). I know RVM can be a pain when you first start
   using it, but you will enjoy life more if you aren't dealing with conflicting
   gems all the time.  Note: do **NOT** install RVM as root.

   First you must configure your terminal emulator to act as a login shell.  In
   gnome-terminal, go to "Edit -> Profile Preferences -> Title and Command".
   Check the box reading "Run command as login shell."  In xfce4-terminal, go to
   "Edit -> Preferences" and check the "Run command as login shell" box.  See
   <https://rvm.io/integration/gnome-terminal>

   Start a new terminal and follow the
   [instructions](https://rvm.io/rvm/security) and then run

   ```
   $ rvm install ruby-2.7.1
   ```

   The documentation for RVM is extensive so don't be afraid to read it.
1. Go into your checkout directory and run `bundle install`
1. Render the site with `bundle exec jekyll serve --watch`.  (See Advanced Workflow section
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
   `jekyll serve --livereload`.  This command calls integrates the
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
page is 'foo.md') and insert it into YAML hierarchy under the appropriate
project and appropriate topic.  If you forget to include your page in the
hierarchy, Jekyll will issue a warning when it is rendering the site.

# Deployment
1. Submit your changes as a PR.  The GitHub Actions continuous integration hook
   will run automatically.  If the build fails, correct it.  Otherwise, when the
   PR is merged into main, a second workflow will run and deploy the site to 
   the Github Pages.
1. The CI settings are in `.github/workflows`. `pr_verification.yml` handles 
   pull requests and `deploy.yml` handles deployment.
1. If you need to work more extensively with the CI, the GitHub actions are
   [documented exceptionally well](https://docs.github.com/en/actions)

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

# Continuous Integration
The GitHub Actions CI workflow we use is based on a default Jekyll building
workflow defined
[here](https://github.com/actions/starter-workflows/blob/main/pages/jekyll-gh-pages.yml).
Ours is slightly different due to additional dependencies such as plantuml.

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

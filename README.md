# Getting Started
1. `yum install nodejs python-pygments ruby-devel libyaml libxslt-devel`
2. Install RVM. Yes, I know RVM can be a pain when you first start using it, but OpenShift uses Ruby 1.9.3
   and the fact is there are some small compatibility issues between 2.0.0 and 1.9.3. Note: do **NOT** install
   RVM as root.

   ```
   $ curl -sSL https://get.rvm.io | bash -s stable --ruby=ruby-1.9.3-p545 --ruby=ruby-2.0.0-p353 --with-gems=rhc
   # The command below will insure that when you install subsequent Ruby versions, the 'rhc' gem will be installed.
   $ echo "rhc" >> ~/.rvm/gemsets/global.gems
   $ rvm --default use 2.0.0-p353
   ```

   Now you must configure your terminal emulator to act as a login shell.  In gnome-terminal, go to "Edit ->
   Profile Preferences -> Title and Command".  Check the box reading "Run command as login shell."  In xfce4-terminal,
   go to "Edit -> Preferences" and check the "Run command as login shell" box.  See
   <https://rvm.io/integration/gnome-terminal>

   With these settings, RVM will use Ruby 2.0.0 as a default.  However, when you `cd` to the website directory
   RVM will detect the .ruby-version and .ruby-gemset files and switch to Ruby 1.9.3 and the candlepinproject.org
   gemset.  The documentation from RVM is extensive so don't be afraid to read it.
3. Go into your checkout directory and run `bundle install`
4. Render the site with `jekyll serve --watch`.  (See Advanced Workflow section for tips on getting real time
   previews of your updates).
5. Make changes and save.  If you wish to create a news item, run `bin/site-tool post "My Title"`.  That
   command will create a file with the correct name and format and open your editor as defined by VISUAL
   or EDITOR.  You can use a different editor with the `--editor` option.
6. Jekyll will automatically render your changes.

# Advanced Workflow
1. *Optional*: Open port 4000 in your firewall so others can see your local site

    ```
    $ firewall-cmd --add-port=4000/tcp --permanent
    ```
2. If you wish to see real time previews of your updates (i.e. if you don't
   want to hit the refresh button all the time), then you can use
   `bin/site-tool serve`.  This command is a wrapper around Jekyll but uses the
   [LiveReload protocol](http://feedback.livereload.com/knowledgebase/articles/86174-livereload-protocol)
   with a tool called [Guard](https://github.com/guard/guard).  Guard is very
   powerful and I recommend reading the documentation, but all you really need
   to know to get started is that you exit Guard by hitting Ctrl-D or by typing
   "e" or "exit".

   Guard will print some output and you should see a notice that Jekyll is
   serving on port 4000 and that LiveReload is waiting for a browser to
   connect.  Go to http://localhost:4000 and visit a page.  When you edit that
   page's source Markdown file and save, Guard will see the file modification
   and trigger a site build.  LiveReload will then refresh your browser for
   you if your browser is connected.  Sometimes it is a bit tricky to get the browser
   to make the initial WebSockets connection.  You may have to refresh or shift-refresh
   a few times.  You're connected when you see the "Browser connected" message on
   the Guard console.

3. **Extreme ProTip**: Unfortunately, Jekyll is a bit simplistic in how it
   regenerates sites.  It regenerates everything instead of just what it needs
   to (improving this is on the roadmap for Jekyll 2.0).  I find waiting for
   the entire site to render to be tedious, so there is a faster way to preview
   changes if you're only working on a few pages:

   ```
   $ bin/site-tool isolate path/to/source/file.md
   ```
   Using `isolate` will only render and serve the files you give as arguments
   plus a few other dependencies like CSS files.  You can provide as many
   source files as you like if you're working with more than one pages at a
   time.  The isolate command works by telling Jekyll to ignore everything but
   the files you specify.  The isolate command also includes the LiveReload
   functionality.

# Deployment
1. `yum install rhc`
2. `rhc setup`
3. Go into your checkout.  You'll need to add the Openshift metadata and remote to your .git/config.
   To automate this, I've created a little script.  Simply run `bin/site-tool bootstrap`.  You should
   now be able to use `rhc` to issue commands to the app on Openshift.
4. When you are ready to deploy, `git push origin master; git push openshift master`.  Currently you must
   push to both locations!  Github is the upstream and the Openshift repo is where we build from.  This
   double repo situation is annoying and I plan on fixing it, but for now just remember to push to both
   places.
5. When you push to Openshift, it will fire a Jenkins build at <http://build-candlepinproject.rhcloud.com>, if
   your build fails (and they do sometimes because Jenkins gets a bad build node or the stars are misaligned), then
   you need to log in to Jenkins (see awood for your account and password if you don't know it) and trigger the
   build manually.  We use Jenkins builds because even though they can be flakey, they prevent a broken application
   from being deployed (i.e. `jekyll build` has to return successfully before the app will deploy).  The Openshift
   relevant files are in the repo in the .openshift directory.

# Syntax Highlighting
Syntax highlighting is provided by [Pygments](http://pygments.org) (more specifically by
Pygments.rb -- a Ruby binding to Pygments).  Set the highlighting on a code block by providing
a lexer name after the three backticks that indicate the beginning of a code block.

The list of lexers is available at <http://pygments.org/docs/lexers/>, but in general they are
named like you would expect.  The most common ones we use are

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

A special note about the console lexer: if the line is a command, you must begin with a "$", "#", or "%"
otherwise the text will be treated as output.  E.g.

**Correct**

```console
$ ./subscription-manager
```

**INCORRECT**

```console
./subscription-manager
```

# Gotchas
* In Markdown, whitespace matters!  Specifically, when you're in a block (like a list element in a bulleted list)
  you need to make sure all sub-blocks have the same initial indentation.

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

* In Less, you must use semicolons to separate parameters to mixins and not commas. However, Less' functions
  do use commas.
  E.g. .my\_mixin(18px; \#deadbeef) versus darken(\#deadbeef, 10%)
  See <http://lesscss.org/features/#mixins-parametric-feature-mixins-with-multiple-parameters>
* Be careful with internal links.  Preface them with {{ site.baseurl }} if they are in another direcotry.
  See <http://jekyllrb.com/docs/github-pages/#project_page_url_structure>
* The URLs for all posts and pages contain a leading slash so there is no need to provide one.  E.g. Linking to a post
  would use {{ site.baseurl }}{{ post.url }}

# Tips
* If you want to see an overview of an object in Liquid, filter it through the debug filter from \_plugins.  E.g. {{ page | debug }}
* To find code blocks missing a lexer, install pcre-tools and use the following `pcregrep -r -M -n '^$\n^```$' *`
* Vim associates '.md' files with Modula-2.  Add the following to your .vimrc to change the association:

  ```
  autocmd BufNewFile,BufReadPost *.md set filetype=markdown
  ```

# References
* We use RVM to manage Ruby versions and gemsets.  See <https://rvm.io/#docindex>
* Jekyll is the engine used to create the site.  There is very good documentation at
  <http://jekyllrb.com/docs/home/>
* We are using Kramdown as our Markdown renderer. There is a quick reference at
  <http://kramdown.gettalong.org/quickref.html> and a more complete syntax guide at
  <http://kramdown.gettalong.org/syntax.html>
* The CSS is written using Less <http://lesscss.org>.
  * The features are demonstrated at <http://lesscss.org/features/>
  * The functions are explained at <http://lesscss.org/functions/>
* The JS and theming are courtesy of Bootstrap <http://getbootstrap.com/> although
  I did strip out some of the JS that we probably would not use like the carousel and
  modal dialog functions.

# Openshift Details
Right now, we have the BUNDLE_WITHOUT environment variable set to "development"
to exclude gems that are in the development group in the Gemfile.  If you ever
need to change that then run the following in your Openshift app checkout.

```
$ rhc set-env BUNDLE_WITHOUT="development another_group"
```

You can view the current custom environment variables with

```
$ rhc env list
```

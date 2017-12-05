[![Build Status](https://travis-ci.org/candlepin/candlepinproject.org.png?branch=master)](https://travis-ci.org/candlepin/candlepinproject.org)

# Getting Started
1. `yum install python-pygments gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel plantuml graphviz`

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
   $ rvm install ruby-2.3.4
   ```

   The documentation for RVM is extensive so don't be afraid to read it.
1. Go into your checkout directory and run `bundle install`
1. (Optional) Install and configure Travis.  This will allow you to interact
   with the continuous integration environment from the command line.

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
   automatically.  If the build fails, correct it.  Otherwise, when the PR is
   merged into master, a webhook will inform Openshift and Openshift will
   rebuild and deploy the application.  Just for reference, the webhook URL can
   be found in the Openshift console by going to the "Configuration" tab for a
   BuildConfig.  The secret to use can be found under the "triggers" section if
   you select "Edit YAML" under "Actions" for a BuildConfig.
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
To interact with Openshift, you will need to install the command line client
`oc`.  It is available in DNF as a package named `origin-clients` but as a
fairly old version.  Instead I grabed it from the
[documenation](https://docs.openshift.com/enterprise/3.0/cli_reference/get_started_cli.html)
which has a download link that will require you to log in to the Red Hat portal.
Once you have the file, unzip it and place the `oc` file in a directory on your
path.  I have a directory `~/bin` that is on my path, so that was the most
convenient place for me.

Next you will need to authenticate.  Run `oc login` and follow the prompts.

Due to our use of PlantUML (which requires Java), we cannot use one of the stock
build images provided by Openshift since the stock containers just provide
one language stack each.  We have to build our own image which is defined in
`Dockerfile` and references other files under `.s2i`.  If you find yourself
needing to modify the build image, you will need to install both Docker and the
[`s2i` tool](https://github.com/openshift/source-to-image).  Like `oc`, `s2i` is
a statically linked binary, so you'll need to download the appropriate tarball
for your architecture and then place `s2i` in a directory on your path.

If you make changes to the Dockerfile, you should test them first.

* Build the image with `docker build -t candlepin/website-ruby-23`
* Run `s2i build --exclude="" . candlepin/website-ruby-23 website`.
  That will generate the application image using custom scripts inserted into
  `website-ruby-23` from the `.s2i/bin` directory.
* Test everything by starting a container using `docker run -p 8088:8080 --rm
  -ti website` and browsing the site at http://localhost:8088.  (Note, I
  surfaced the container's port 8080 as 8088 since Tomcat normally uses 8080).
* Hit CTRL-C to stop the container (and the `--rm` argument will remove the
  container immediately).

If your changes work, you'll need to propagate them.

* You will need to push the image to Docker Hub using the Candlepin account
  Run `docker login` and enter the credentials (see Al for them).
* Run `docker push candlepin/website-ruby-23:latest` to push the image.

Openshift should be configured to watch that image repository and rebuild
everything when it detects a change to the image.

If you are starting with a brand new project, you'll need to import the image
initially using `oc import-image --from='docker.io/candlepin/website-ruby-23' --confirm candlepin/website-ruby-23:latest`

Then create your application with `oc new-app candlepin/website-ruby-23~https://github.com/candlepin/candlepinproject.org` or you can use the web console if you want.

# Environment Variables and Build and Run Processes
Any environment variables that we need to define (such as the BUNDLE_WITHOUT
variable to exclude gems from a group in the Gemfile) are defined in
`.s2i/environment`.  If you ever need to change that then you will need to
rebuild the build image as described above.

Any changes to the site building process (e.g. some pre-processing step needs to
be run before `jekyll build`) or run process (e.g. additional arguments given to
Puma) would be made in `.s2i/bin/assemble` and `.s2i/bin/run` respectively.
Again, you would need to rebuild the build image and push it to Docker Hub.

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

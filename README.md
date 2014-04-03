# Getting Started
1. `yum install rhino python-pygments ruby-devel rubygem-rugged`
2. `gem install bundler`
3. `bundle install`

# Workflow
1. Install Auto Reload from <https://addons.mozilla.org/en-US/firefox/addon/auto-reload/>
2. In Firefox, go to Tools -> Auto Reload Preferences. Create an entry for http://localhost:4000. Click
   'Add Directory...' and point to the `$CHECKOUT_DIR/_site` directory. (This directory may not exist
   yet if Jekyll has not yet rendered the site.) Uncheck the 'Reload active tab only' box.
3. *Optional* Open port 4000 in your firewall so others can see your local site

    ```
    $ firewall-cmd --add-port=4000/tcp --permanent
    ```

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
* In Less, you must use semicolons to separate parameters to mixins and not commas. However, Less' functions
  do use commas.
  E.g. .my_mixin(18px; \#deadbeef) versus darken(\#deadbeef, 10%)
  See <http://lesscss.org/features/#mixins-parametric-feature-mixins-with-multiple-parameters>
* Be careful with internal links.  Preface them with {{ site.baseurl }} if they are in another direcotry.
  See <http://jekyllrb.com/docs/github-pages/>
* The URLs for all posts and pages contain a leading slash so there is no need to provide one.  E.g. Linking to a post
  would use {{ site.baseurl }}{{ post.url }}

# Tips
* If you want to see an overview of an object in Liquid, filter it through the debug filter from _plugins.  E.g. {{ page | debug }}
* To find code blocks missing a lexer, install pcre-tools and use the following `pcregrep -r -M -n '^$\n^```$' *`

# References
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

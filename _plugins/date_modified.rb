#! /usr/bin/env ruby
=begin
  Liquid tag to add the date a source file was last modified in Git.
  If no modification date is found, Jekyll's site.time property is used
  instead. Follows the same sematics as Liquid's "date" filter (AKA
  Ruby's strftime).
  Usage:
    {% date_modified format:'%d %B %Y' %}
  Dependency:
    - rugged
=end
require 'git'
require_relative 'mixins.rb'

module Jekyll
  class DateModifiedTag < Liquid::Tag
    include LogCapable

    def initialize(tag_name, text, tokens)
      @tag_name = tag_name
      @attributes = {}
      text.scan(Liquid::TagAttributes) do |k, v|
        @attributes[k] = v
      end
      @tokens = tokens
      super
    end

    def open_repo(source_root)
      # You can add :log => logger as option when building the Git object for more info.
      if File.directory?(File.join(source_root, '.git'))
        return Git.open(source_root)
      elsif ENV['OPENSHIFT_HOMEDIR']
        root = File.join(ENV['OPENSHIFT_HOMEDIR'], "git", "#{ENV['OPENSHIFT_APP_NAME']}.git")
        logger.debug("", "Reading from Openshift bare repo at #{root}")
        return Git.bare(root)
      else
        return nil
      end
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]
      begin
        repo = open_repo(site.source)
        most_recent = (repo.nil?) ? nil : repo.log.path(page['path']).first
        if most_recent.nil?
          logger.warn("Warning:", "#{page['path']} not found in Git log. Using current time.")
        else
          # See http://alexpeattie.com/blog/working-with-dates-in-git/ for differences in author date
          # and commit date
          mtime = most_recent.author_date
        end
      rescue => e
        logger.error("Error:", "Could not read Git repository! Defaulting to current time. #{e}")
      end
      # Set mtime to the site's generation time if we hit a RepositoryError or nil obj
      mtime ||= site.time

      format = @attributes['format']
      # Delegate to Liquid's date filter
      # Basically, we're doing the below but more efficiently. The
      # context[format] will resolve the format value within the context (which
      # we'd want to do if the user has a variable set with the format in it
      # for example)
      #
      # template = Liquid::Template.parse("{{ mtime | date: #{format} }}")
      # template.render!({"mtime" => mtime})
      context.invoke('date', mtime, context[format])
    end
  end
end

Liquid::Template.register_tag('date_modified', Jekyll::DateModifiedTag)

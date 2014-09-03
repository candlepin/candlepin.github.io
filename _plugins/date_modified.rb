#! /usr/bin/env ruby
=begin
  Liquid tag to add the date a source file was last modified in Git.
  If no modification date is found, Jekyll's site.time property is used
  instead. Follows the same semantics as Liquid's "date" filter (AKA
  Ruby's strftime).
  Usage:
    {% date_modified format:'%d %B %Y' %}
=end
require 'date'
require 'git'
require_relative 'mixins.rb'

module Jekyll
  class DateModifiedGenerator < Generator
    include LogCapable

    priority :high

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

    def generate(site)
      begin
        repo = open_repo(site.source)
      rescue
        repo = nil
      end

      logger.error("Error:", "Could not read Git repository! Defaulting to current time.") if repo.nil?

      site.pages.each do |page|
        most_recent = (repo.nil?) ? nil : repo.log.path(page.path).first
        if most_recent.nil?
          # Don't spam the console with warnings if there is no repo at all.
          logger.warn("Warning:", "#{page['path']} not found in Git log. Using current time.") unless repo.nil?
          # Set date_modified to the site's generation time if we hit a nil obj
          page.data['date_modified'] = site.time
        else
          # See http://alexpeattie.com/blog/working-with-dates-in-git/ for differences in author date
          # and commit date
          page.data['date_modified'] = most_recent.author_date
        end
      end
      site.data['new_pages'] = newest_changes(site)
    end

    def newest_changes(site)
      # Remove pages tagged with 'no_date', sort by date descending, and take the top 50
      page_list = site.pages.reject { |p| p['no_date'] }
      page_list = page_list.sort_by { |p| p.data['date_modified'] }.reverse
      page_list = page_list[0..49]

      # Group the pages together by the day they were modified
      day_groups = page_list.group_by do |p|
        p.data['date_modified'].strftime("%-d %B %Y")
      end

      # Create a sorted list of keys so we can access day_groups in order
      keys = day_groups.keys.sort_by { |p| Date.parse(p) }.reverse

      new_pages = []
      keys.each do |k|
        new_pages.concat(day_groups[k].sort_by { |p| p['title'] })
      end
      new_pages
    end
  end

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

    def render(context)
      page = context.registers[:page]
      format = @attributes['format']

      # Delegate to Liquid's date filter
      # Basically, we're doing the below but more efficiently. The
      # context[format] will resolve the format value within the context (which
      # we'd want to do if the user has a variable set with the format in it
      # for example)
      #
      # template = Liquid::Template.parse("{{ mtime | date: #{format} }}")
      # template.render!({"mtime" => mtime})
      context.invoke('date', page['date_modified'], context[format])
    end
  end
end

Liquid::Template.register_tag('date_modified', Jekyll::DateModifiedTag)

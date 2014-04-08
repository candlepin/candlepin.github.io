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
require 'rugged'

module Jekyll
  class DateModifiedTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      @tag_name = tag_name
      @attributes = {}
      text.scan(Liquid::TagAttributes) do |k, v|
        @attributes[k] = v
      end
      @tokens = tokens
      super
    end

    def logger
      Jekyll.logger
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]
      source_root = site.source
      begin
        repo = Rugged::Repository.new(Rugged::Repository.discover(source_root))
        index = repo.index
        obj = index[page['path']]
        if obj.nil?
          logger.warn("Warning:", "#{page['path']} not found in Git index. Using current time.")
        else
          mtime = obj[:mtime]
        end
      rescue Rugged::RepositoryError
        logger.error("Error:", "Missing Git repository! Defaulting to current time.")
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

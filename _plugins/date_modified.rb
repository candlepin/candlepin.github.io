#! /usr/bin/env ruby
=begin
  Jekyll generator to add the date a source file was last modified in Git.
  If no modification date is found, Jekyll's site.time property is used
  instead.
  Usage:
    {{ page.date_modified }}
  Dependency:
    - rugged
=end
require 'rugged'

module Jekyll
  class Page
    attr_accessor :date_modified

    # Hack to_liquid to expose our date_modified property
    def to_liquid(attrs = nil)
      extra_attrs = self.class::ATTRIBUTES_FOR_LIQUID + %w[date_modified]
      super(attrs || extra_attrs)
    end
  end

  class DateModifiedGenerator < Generator
    safe true
    priority :normal

    def logger
      Jekyll.logger
    end

    def generate(site)
      $stderr.puts # Places newline after "Generating..."
      source_root = site.source
      begin
        repo = Rugged::Repository.new(File.join(source_root, ".git"))
        index = repo.index
        site.pages.each do |page|
          obj = index[page.path]
          logger.warn("Warning:", "#{page.path} not found in Git index. Using current time.") unless obj
          mtime = obj.nil? ? nil : obj[:mtime]
          page.date_modified = mtime || site.time
        end
      rescue Rugged::RepositoryError
        logger.error("Error:", "Missing Git repository! Defaulting to current time.")
        site.pages.each do |page|
          page.date_modified = site.time
        end
      end
    end
  end
end

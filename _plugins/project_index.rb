#! /usr/bin/env ruby
=begin
  Jekyll generator to create an index page breaking down items in the directory
  by category.
=end

require 'set'
module Jekyll
  class ProjectIndexPage < Page
    attr_reader :project_categories
    attr_reader :project_pages

    CATEGORY_ATTRIBUTES_FOR_LIQUID = %w[
      project_categories
      project_pages
    ]

    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = "project_index.html"

      self.process(@name)
      self.read_yaml(File.join(base, site.config['layouts']), 'project_index.html')

      project_categories = Set.new(['uncategorized'])
      project_pages = Set.new
      Jekyll.logger.info("Dir", dir)
      #site.pages.each { |p| Jekyll.logger.info("Path", File.dirname(p.path)); Jekyll.logger.info("Dir", "#{dir}") }
      site.pages.select { |page| File.dirname(page.path) =~ %r(#{dir}$) }.each do |p|
        # FIXME fix for multiple categories
        project_categories << p.categories
        project_pages << p
      end
    end

    def to_liquid
      super.to_liquid
      further_data = Hash[CATEGORY_ATTRIBUTES_FOR_LIQUID.map { |attribute|
        [attribute, send(attribute)]
      }]
      data.deep_merge(further_data)
    end
  end

  class ProjectIndexGenerator < Generator
    safe true
    priority :lowest

    def logger
      Jekyll.logger
    end

    def generate(site)
      return unless site.layouts.key? 'project_index'
      logger.abort_with("FATAL:", "Missing 'projects_dir' path in site configuration") if !site.config['projects_dir']

      docs_dir = site.config['projects_dir']
      # for each immediate subdirectory
      Dir.glob("#{docs_dir}/*/").each do |subdir|
        site.pages << ProjectIndexPage.new(site, site.source, subdir)
      end
    end
  end
end

#! /usr/bin/env ruby
=begin
  Liquid tag to create an index breaking down items in the directory
  by category.
=end

require_relative 'mixins.rb'

module Jekyll
  class ProjectCategory < Struct.new(:name, :order, :pages)
    include Liquify
  end

  class ProjectIndexTag < Liquid::Tag
    attr_accessor :tag_name
    attr_accessor :text
    attr_accessor :tokens

    include LogCapable

    def initialize(tag_name, text, tokens)
      super
      @tag_name = tag_name
      @text = text
      @tokens = tokens
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      logger.abort_with("FATAL:", "Missing '#{tag_name}' layout in #{site.config['layouts']}") unless site.layouts.has_key?(tag_name)
      layout = site.layouts[tag_name]

      categories = []
      # Get all the pages in the directory of the page using the tag EXCEPTING the page using the tag
      project_pages = site.pages.select do |p|
        File.dirname(p.path) == File.dirname(page['path']) && p.url != page['url']
      end

      categories = {}
      project_pages.each do |proj_page|
        page_cats = proj_page.data.fetch('categories', 'uncategorized')
        unless page_cats.respond_to?('each')
          page_cats = page_cats.split(%r(\s*,\s*))
        end

        page_cats.each { |c| (categories[c] ||= []) << proj_page }
      end

      project_categories = []
      # Create a set of categories and build ProjectCategory objects from each one
      categories.each_with_object(project_categories) do |(cat, pages), list|
          order = site.config['category-order'].fetch(cat, nil)
          list << ProjectCategory.new(cat, order, pages)
      end
      payload = site.site_payload.deep_merge({"project_categories" => project_categories})

      Liquid::Template.parse(layout.content).render!(payload)
    end
  end
end

Liquid::Template.register_tag('project_index', Jekyll::ProjectIndexTag)

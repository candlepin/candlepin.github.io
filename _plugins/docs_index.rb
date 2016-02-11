#! /usr/bin/env ruby
=begin
  Tag to create a documentation index.
=end

require_relative 'mixins.rb'

module Jekyll
  class TocItem < Struct.new(:level, :number, :name, :link, :has_sublevels)
    include Liquify
  end

  class UncatPage < Struct.new(:name, :link)
    include Liquify
  end

  class IndexGenerator < Generator
    include LogCapable

    # Adds titles of pages to Master Table of Contents.
    # When a page info is extracted from project_pages hash,
    # the page is removed from project_pages. This way we can track
    # uncategorized pages
    def add_titles_and_subsections(sections, project_pages)
      sections.each do |s|
        section_name = s['section']
        page = project_pages.delete(section_name)
        if page.nil?
          logger.abort_with("FATAL:", "Page '#{section_name}.md' that is defined in Master Table of Contents wasn't found!")
        end

        s['section-title'] = page[:title]
        s['subs'] ||= []

        # Each sub is an existing page, add title to each one
        add_titles_and_subsections(s['subs'], project_pages)
      end
    end

    # Takes enriched sections yaml and creates numbered hierarchy
    # of sections
    def build_toc_entries(sections, level, number)
      section_num = 1
      result = []
      sections.each do |s|
        if number == ""
          secnum = section_num.to_s
        else
          secnum = "#{number}.#{section_num.to_s}"
        end
        # This is a little brittle.  We're using the value specified in the YAML file to build the href in the
        # anchor tag, but the values in the YAML files don't have any directory information associated with them.
        # I would prefer to match the s['section'] values to actual Page objects and then use page.url
        result << TocItem.new(level, secnum, s['section-title'], s['section'], s.key?('subs') && s['subs'].length > 0)
        if s.key?('subs')
          result.concat(build_toc_entries(s['subs'], level + 1, secnum))
        end
        section_num = section_num + 1;
      end

      result
    end

    # Retrieve few simple pieces of information for pages on site.
    #
    # Returns a hash indexed by page name. Each element of the hash
    # contains title (:title)
    def pages_by_name(site)
      result = {}
      site.pages.each do |p|
        # Hash key is page name without .md or .html suffix
        clean_name = p.name.gsub(/(\.html$)|(\.md$)/,'')
        next if p.data['toc_display'] == false
        result[clean_name] = { :title => p.data['title'] || p.name }
      end
      result
    end

    INDEX_KEY = "toc".freeze

    def generate(site)
      # Load _data/toc.yaml
      sections_yaml = site.data[INDEX_KEY]
      all_pages = pages_by_name(site)

      # After this method is called, all unused pages will stay in all_pages
      add_titles_and_subsections(sections_yaml, all_pages)
      toc_entries = build_toc_entries(sections_yaml, 1, "")

      uncat=[]
      all_pages.each do |k, v|
        logger.warn("Detected uncategorized page '#{k}'. Please categorize pages in _data/#{INDEX_KEY}.yaml")
        uncat << UncatPage.new(v[:title], k)
      end

      site.data[INDEX_KEY] = {
        'entries' => toc_entries,
        'uncategorized' => uncat
      }
    end
  end

  class IndexTag < Liquid::Tag
    attr_accessor :tag_name
    attr_accessor :text
    attr_accessor :tokens

    include LogCapable

    def initialize(tag_name, text, tokens)
      super
      @tag_name = tag_name
      @text = text.strip
      @tokens = tokens
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]
      logger.abort_with("FATAL:", "Could not find layout named '#{@text}'") unless site.layouts.key?(@text)
      layout = site.layouts[@text]
      payload = Utils.deep_merge_hashes(site.site_payload, { "page" => page })
      Liquid::Template.parse(layout.content).render!(payload)
    end
  end
end

Liquid::Template.register_tag('index', Jekyll::IndexTag)

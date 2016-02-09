#! /usr/bin/env ruby
=begin
  Tag to create a documentation index.
=end

require_relative 'mixins.rb'

module Jekyll
  class TocItem < Struct.new(:level, :number, :name, :link,:has_sublevels)
    include Liquify
  end

  class UncatPage < Struct.new(:name, :link)
    include Liquify
  end

  class DocsIndexTag < Liquid::Tag
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

    # Adds titles of pages to Master Table of Contents.
    # When a page info is extracted from project_pages hash,
    # the page is removed from project_pages. This way we can track
    # uncategorized pages
    def self.add_titles_and_subsections(sections, project_pages)
      sections.each do |s|
        section_name = s['section']
        page = project_pages.delete(section_name)
        if page.nil?
          raise "Page '#{section_name}.md' that is defined in Master Table of Contents wasn't found!"
        end
        s['section-title'] = page[:title]

        s['subs'] ||= []

        # Each sub is an existing page, add title to each one
        DocsIndexTag.add_titles_and_subsections(s['subs'], project_pages)
      end
    end

    # Takes enriched sections yaml and creates numbered hierarchy
    # of sections
    def self.build_toc_items(sections, level, number)
      section_num = 1
      result = []
      sections.each do |s|
        if number == ""
          secnum = section_num.to_s
        else
          secnum = "#{number}.#{section_num.to_s}"
        end
        result << TocItem.new(level, secnum, s['section-title'], s['section'], s.key?('subs') && s['subs'].length > 0)
        if s.key?('subs')
          result.concat(DocsIndexTag.build_toc_items(s['subs'], level + 1, secnum))
        end
        section_num = section_num + 1;
      end

      return result
    end

    # Retrieve few simple pieces of information for pages on site.
    # Excludes this_page.
    #
    # Returns a hash indexed by page name. Each element of the hash
    # contains title (:title)
    def self.pages_by_name(site, this_page)
      result = {}
      project_pages = site.pages.select do |p|
        File.dirname(p.path) == File.dirname(this_page['path']) && p.url != this_page['url']
      end
      project_pages.each do |p|
        # Hash key is page name without .md or .html suffix
        clean_name = p.name.gsub(/(\.html$)|(\.md$)/,'')
        result[clean_name] = { :title => p.data['title'] }
      end
      return result
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      layout = site.layouts[tag_name]

      sections_yaml = page['sections']

      all_pages = DocsIndexTag.pages_by_name(site, page)

      # After this method is called, all unused pages will stay in all_pages
      DocsIndexTag.add_titles_and_subsections(sections_yaml, all_pages)
      tocitems = DocsIndexTag.build_toc_items(sections_yaml, 1, "")

      uncat=[]
      
      all_pages.each do |k, v|
        logger.warn("Detected uncategorized page '#{k}'. Please categorize all your pages in index.md")
        uncat << UncatPage.new(v[:title], k)
      end
      
      #Signal to the template, so that it can include necessary Javascript
      page['mastertoc'] = true
      payload = Utils.deep_merge_hashes(site.site_payload, { 'tocitems' => tocitems, 'uncategorized' => uncat})

      Liquid::Template.parse(layout.content).render!(payload)
    end
  end
end

Liquid::Template.register_tag('docs_index', Jekyll::DocsIndexTag)

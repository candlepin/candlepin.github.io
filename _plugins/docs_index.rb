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

    #Adds titles of pages to Master Table of Contents and also 
    #adds headings of pages to Master Table of Contents.
    # When a page info is extracted from project_pages hash,
    #the page is removed from project_pages. This way we can track
    # uncategorized pages
    def self.addTitlesAndSubsections(sections, project_pages) 
      sections.each do |s|
        section_name = s["section"]
        page = project_pages.delete(section_name)
        if (page.nil?)
          raise "Page '#{section_name}.md' that is defined in Master Table of Contents wasn't found!"
        end
        s['section-title']=page[:title]
        
        s['subs'] ||= []
        
        #Each sub is an existing page, add title to each one
        DocsIndexTag.addTitlesAndSubsections(s["subs"],project_pages)
        
        #As the last thing, add all the anchors to page headings
        page[:headings].each do |heading| 
          s["subs"] << {'section'=> section_name+"#"+heading[:id], "section-title"=> heading[:text]}
        end
      end
    end

    #Takes enriched sections yaml and creates numbered hierarchy
    # of sections     
    def self.buildTocItems(sections, level, number) 
      sectionNum = 1
      result = []
      sections.each do |s|
        if (number == "")
          secnum = sectionNum.to_s
        else
          secnum = number+"."+sectionNum.to_s
        end
        result << TocItem.new(level, secnum, s['section-title'], s['section'], s.key?("subs") && s["subs"].length > 0)
        if s.key?("subs")
          result.concat DocsIndexTag.buildTocItems(s["subs"], level+1, secnum)
        end
        sectionNum = sectionNum + 1;
      end

      return result
    end 
   
    # Retrieve few simple pieces of information for pages on site.
    # Excludes thisPage.
    #
    # Returns a hash indexed by page name. Each element of the hash
    # contains title (:title) of the page and an array of headings (:headings) in that page 
    # This method parses the page using regex. I think its 
    # much faster than parsing the whole page using Kramdown parser when
    # we only need heading names.
    def self.pagesByName(site, thisPage) 
      result = {}
      project_pages = site.pages.select do |p|
        File.dirname(p.path) == File.dirname(thisPage['path']) && p.url != thisPage['url']
      end
      project_pages.each do |p|
        h = []
        p.content.each_line do |line|
          #Remove span tags from the line
          
          line = line.gsub(/\<span[^>]*\>/,'')
          line = line.gsub(/\<\/span\>/,'')
          # Regex finds <h1 and extracts the id attribute and the inner of the 
          # h1 tag
          match = line.match(/\<h1[ ]+id=\"([^\"]+)\"\>([^\<]+)/)
          if (match != nil)
            if (match.captures.length < 2)
              raise "The following line in page #{p.name} appears to be h1 "+
                "tag, but I couldn't extract id and heading text \n"+line
            end
            h << {:id=> match.captures[0], :text => match.captures[1]}
          end
        end
        
        #Hash key is page name without .md suffix
        #Each page contains array of headings and each page has a title
        result[p.name[0..-4]] = {:headings =>  h, :title => p.data['title']}
      end 
      return result
    end
     
    def render(context)
      site = context.registers[:site]
      page = context.registers[:page]

      layout = site.layouts[tag_name]
      
      sections_yaml = page["sections"]
      
      all_pages = DocsIndexTag.pagesByName(site,page)
      
      #After this method is called, all unused pages will stay in all_pages
      DocsIndexTag.addTitlesAndSubsections(sections_yaml, all_pages)
      tocitems = DocsIndexTag.buildTocItems(sections_yaml, 1, "")
      
      uncat=[]
      all_pages.each do |k, v|
        uncat << UncatPage.new(v[:title],k)
      end
      #Signal to the template, so that it can include necessary Javascripts 
      page["mastertoc"] = true
      payload = Utils.deep_merge_hashes(site.site_payload, {"tocitems"=>tocitems, "uncategorized"=>uncat})

      Liquid::Template.parse(layout.content).render!(payload)
    end
  end
end

Liquid::Template.register_tag('docs_index', Jekyll::DocsIndexTag)

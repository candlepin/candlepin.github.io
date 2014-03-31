#! /usr/bin/env ruby
# Courtesy http://wolfslittlestore.be/2013/10/rendering-markdown-in-jekyll/
=begin
  Jekyll tag to include Markdown text from _includes directory preprocessing with Liquid.
  Usage:
    {% include_markdown <filename> %}
  Dependency:
    - kramdown
=end
module Jekyll
  class IncludeMarkdownError < StandardError
  end

  class MarkdownTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end
    require "kramdown"
    def render(context)
      begin
        site = context.registers[:site]
        template = File.read(File.join(site.source, Jekyll::Tags::IncludeTag::INCLUDES_DIR, @text))
        liquified = Liquid::Template.parse(template).render!(site.site_payload)
        Kramdown::Document.new(liquified).to_html
      rescue => e
        raise IncludeMarkdownError.new(e.message)
      end
    end
  end
end

Liquid::Template.register_tag('include_markdown', Jekyll::MarkdownTag)

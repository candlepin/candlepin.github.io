#! /usr/bin/env ruby
# Courtesy https://github.com/navarroj/krampygs and
# http://bloerg.net/2013/03/07/using-kramdown-instead-of-maruku.html
require 'kramdown'
require 'pygments'
require 'typogruby'

module Kramdown
  module Converter
    class Pygs < Html
      def convert_codeblock(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr) || @options[:coderay_default_lang]
        code = pygmentize(el.value, lang)
        code_attr = {}

        if lang
          css_class = "language-#{lang}"
          code_attr['class'] = css_class
          if attr.has_key?('class')
            attr['class'] += " #{css_class}"
          else
            attr['class'] = css_class
          end
        end
        "#{' '*indent}<pre#{html_attributes(attr)}><code#{html_attributes(code_attr)}>#{code}</code></pre>\n"
      end

      def convert_codespan(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr) || @options[:coderay_default_lang]
        code = pygmentize(el.value, lang)
        if lang
          if attr.has_key?('class')
            attr['class'] += " language-#{lang}"
          else
            attr['class'] = "language-#{lang}"
          end
        end
        "<code#{html_attributes(attr)}>#{code}</code>"
      end

      def pygmentize(code, lang)
        if lang
          Pygments.highlight(code,
            :lexer => lang,
            :options => { :encoding => 'utf-8', :nowrap => true })
        else
          escape_html(code)
        end
      end
    end
  end
end

class Jekyll::Converters::Markdown::KramdownPygments
  def initialize(config)
    @config = config
  end

  def convert(content)
    html = Kramdown::Document.new(content, {
        :auto_ids             => @config['kramdown']['auto_ids'],
        :auto_ids_prefix      => @config['kramdown']['auto_ids_prefix'],
        :footnote_nr          => @config['kramdown']['footnote_nr'],
        :entity_output        => @config['kramdown']['entity_output'],
        :toc_levels           => @config['kramdown']['toc_levels'],
        :smart_quotes         => @config['kramdown']['smart_quotes'],
        :coderay_default_lang => @config['kramdown']['default_lang'],
        :input                => @config['kramdown']['input'],
        :hard_wrap            => @config['kramdown']['hard_wrap'],
        :parse_block_html     => @config['kramdown']['parse_block_html'],
    }).to_pygs
    return Typogruby.improve(html)
  end
end

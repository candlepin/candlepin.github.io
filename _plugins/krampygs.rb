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
        code = pygmentize(el.value, lang, :classes => attr['class'])
        "#{code}\n"
      end

      def convert_codespan(el, indent)
        attr = el.attr.dup
        lang = extract_code_language!(attr) || @options[:coderay_default_lang]
        code = pygmentize(el.value, lang, :wrap => false)
        if lang
          if attr.has_key?('class')
            attr['class'] += " language-#{lang}"
          else
            attr['class'] = "language-#{lang}"
          end
        end
        "<code#{html_attributes(attr)}>#{code}</code>"
      end

      def pygmentize(code, lang, opts)
        wrap = (opts.key?(:wrap)) ? opts[:wrap] : true
        classes = (opts.key?(:classes)) ? opts[:classes] : nil
        lang ||= 'text'

        pyg_opts = {
          :encoding => 'utf-8',
          :nowrap => (!wrap).to_s,
          # cssclass and line number options only apply if nowrap is false
          :cssclass => "language-#{lang} highlight #{classes}",
        }

        if classes =~ /\bnumbered\b/
          pyg_opts[:lineanchors] = 'line'
        end

        Pygments.highlight(code,
          :lexer => lang,
          :options => pyg_opts)
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

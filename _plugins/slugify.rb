#! /usr/bin/env ruby
=begin
  Liquid tag to create a "slug" (all lower-case, no non-word characters) from a string
=end

require 'stringex_lite'

module Jekyll
  module Slugify
    def slugify(input)
      input ||= ''
      input.to_url
    end
  end
end

Liquid::Template.register_filter(Jekyll::Slugify)

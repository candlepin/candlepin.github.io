#! /usr/bin/env ruby
=begin
Jekyll doesn't print a newline after it begins site generation and it makes the
log messages look all ugly.  This fixes it.
=end

module Jekyll
  class NewLineGenerator < Generator
    priority :highest
    safe :true

    def generate(site)
      $stderr.puts
    end
  end
end

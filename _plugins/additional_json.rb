#! /usr/bin/env ruby
=begin
Jekyll generator that will load JSON specified in the YAML front-matter, send it through
a Ruby module to transform it, and then make it available to Liquid for templating.

How to Use:
1. Place your JSON file in "_data".
2. In the YAML front-matter for a page, add "additional_json: <JSON_FILE_NAME>"
3. The JSON is now available via page.json

Optionally, if you wish to transform your JSON in some way, create a file with the same
name as your JSON file but with a ".rb" extension.  In the ".rb" file, create a Module named
"Mutate" that defines a "mutate" method.  When the page object is created, the plugin will load
the Mutate module, call the mutate method on the JSON, and then unload the Mutate module.  The
mutated JSON is cached so it will only regenerate if the underlying JSON file is modified.
=end

require 'pathname'
require 'json'
require_relative 'mixins.rb'

module Jekyll
  # Items of this class will never be written to the rendered site, but we
  # will keep track of their modification times so we know whether to call
  # generate on dependent items again.
  class SilentStaticFile < StaticFile
    def write(dest)
      @@mtimes[path] = mtime
      false
    end
  end

  class AdditionalJsonPage < Page
    # A cache of the mutated JSON
    @@mutations = Hash.new

    attr_reader :json_path

    include LogCapable

    def json
      @@mutations[json_path]
    end

    def initialize(site, base, dir, name, json_file)
      super(site, base, dir, name)
      @json_path = json_file.path

      return unless json_file.modified? || !@@mutations.has_key?(json_path)

      json = JSON.load(File.open(json_path))
      mutate_file = json_path.chomp(File.extname(json_path)) + ".rb"
      if File.exists?(mutate_file)
        begin
          load(mutate_file)
          extend Mutate
          logger.info("Mutating:", "#{File.basename(json_path)} with #{File.basename(mutate_file)}")
          json = mutate(json)
        rescue => e
          logger.error("Mutation failed:", e)
          raise
        ensure
          # unload the mutation module once we are finished with it
          Object.send(:remove_const, :Mutate) if Object.send(:const_defined?, :Mutate)
        end
      end
      @@mutations[json_path] = json
    end

    def to_liquid(attrs = nil)
      standard_attrs = self.class::ATTRIBUTES_FOR_LIQUID + ['json']
      super(attrs || standard_attrs)
    end
  end

  class AdditionalJsonPageGenerator < Generator
    safe true
    priority :low

    include LogCapable

    def generate(site)
      site.pages.clone.select { |p| p.data.has_key?("additional_json") }.each do |page|
        site.pages.delete(page)
        json_file = SilentStaticFile.new(
                      site,
                      site.source,
                      site.config['data_dir'],
                      page.data['additional_json'])
        begin
          File.open(json_file.path)
        rescue
          logger.error("FATAL:", "Couldn't open #{json_file.path}")
          raise
        end

        site.static_files << json_file
        site.pages << AdditionalJsonPage.new(site, site.source, page.dir, page.name, json_file)
      end
    end
  end
end


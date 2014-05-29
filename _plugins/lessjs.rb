#! /usr/bin/env ruby
# Inspired by https://gist.github.com/andyfowler/642739 and https://github.com/zroger/jekyll-less
require 'pathname'
require_relative 'mixins.rb'

module Jekyll
  class LessCssFile < StaticFile
    include LogCapable

    def initialize(less_dependencies, *args)
      @less_dependencies = less_dependencies
      super(*args)
    end

    def destination(dest)
      File.join(dest, @dir, @name.sub(LessJsGenerator::LESS_EXT_REGEX , '.css'))
    end

    def modified?
      super || @less_dependencies.any? { |f| f.modified? }
    end

    def write(dest)
      dest_path = destination(dest)
      return false if File.exist?(dest_path) and !modified?

      # Update the mtimes on the less_dependencies manually since we've removed
      # these files from site.static_files and their write method will never get
      # called
      @less_dependencies.each do |f|
        @@mtimes[f.path] = f.mtime
      end
      @@mtimes[path] = mtime

      FileUtils.mkdir_p(File.dirname(dest_path))

      command = [@site.config['lessc'],
                 path,
                 dest_path
                 ].join(' ')
      logger.info("Compiling LESS:", command)
      result = `#{command}`

      raise IOError.new("LESS compilation error: #{result}".red) if $?.to_i != 0
    end
  end

  # Required in your _config.yml:
  #   lessc: the path to a local less.js/bin/lessc
  #   less_artifacts: a list of globs.  Files matching the globs are sent to lessc.
  class LessJsGenerator < Generator
    safe true
    priority :high

    LESS_EXT_REGEX = /\.less$/i

    include LogCapable

    def validate(config)
      unless config.has_key?('lessc')
        logger.abort_with("FATAL:", "Missing 'lessc' path in site configuration")
      end
      unless config.has_key?('less_artifacts')
        logger.abort_with("FATAL:", "Missing 'less_artifacts' value in site configuration")
      end
    end

    def generate(site)
      validate(site.config)

      deployed_artifacts = site.config['less_artifacts'].map { |glob| Dir.glob(File.join(site.source, glob)) }
      deployed_artifacts.flatten!

      # Dependencies are all the *.less files that we don't explicitly send to the compiler via
      # the less_artifacts config value
      less_dependencies, site.static_files = site.static_files.clone.partition do |f|
        f.path =~ LESS_EXT_REGEX && !deployed_artifacts.include?(f.path)
      end

      site.static_files.clone.select { |f| deployed_artifacts.include?(f.path) }.each do |artifact|
        site.static_files.delete(artifact)
        source_path, file = Pathname.new(artifact.path).split
        relative_path = source_path.relative_path_from(Pathname.new(site.source))
        site.static_files << LessCssFile.new(less_dependencies, site, site.source, relative_path, file.to_s)
      end
    end
  end
end

#! /usr/bin/env ruby
# Inspired by https://gist.github.com/andyfowler/642739
require 'pathname'

module Jekyll
  class LessCssFile < StaticFile
    def write(dest)
      # do nothing
    end
  end

  # Required in your _config.yml:
  #   lessc: the path to a local less.js/bin/lessc
  #   less_artifacts: a list of globs.  Files matching the globs are sent to lessc.
  class LessJsGenerator < Generator
    safe true
    priority :low

    def logger
      Jekyll.logger
    end

    # This method creates the CSS from the LESS file and places it in the Jekyll content directory rather than
    # in _site. This behavior is a work-around for GitHub's limitation against running Jekyll plugins.
    def generate(site)
      source_root = Pathname.new(site.source)
      dest_root = Pathname.new(site.dest)
      less_ext = /\.less$/i

      logger.abort_with("FATAL:", "Missing 'lessc' path in site configuration") if !site.config['lessc']
      logger.abort_with("FATAL:", "Missing 'less_artifacts' value in site configuration") if !site.config['less_artifacts']

      less_artifacts = site.config['less_artifacts'].map { |glob| Dir.glob(File.join(source_root, glob)) }
      less_artifacts.flatten!

      # static_files have already been filtered against excludes, etc.
      if site.static_files.any? { |sf| sf.path =~ less_ext && sf.modified? }
        #compile top level artifacts
        less_artifacts.each do |artifact|
          source_path, file = Pathname.new(artifact).split
          generated_directory = source_path.join("generated")
          css_name = file.to_s.gsub(less_ext, '.css')

          dest_dir = dest_root.join(generated_directory)
          FileUtils.mkdir_p(dest_dir)
          command = [site.config['lessc'],
                     artifact,
                     generated_directory.join(css_name)
                     ].join(' ')

          logger.info("Compiling LESS:", command)

          result = `#{command}`

          raise IOError.new("LESS compilation error: #{result}".red) if $?.to_i != 0

          relative_path = generated_directory.relative_path_from(source_root)
          site.static_files << LessCssFile.new(site, site.source, relative_path, css_name)
        end
      end
    end
  end
end

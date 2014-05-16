#! /usr/bin/env ruby

require 'safe_yaml/load'
require 'set'
require 'uri'

module Rack
  class IsolationInjector
    def initialize(app, options={})
      @app = app
      @options = options
    end

    ISOLATION_FILE = '.isolation_config.yml'

    def call(env)
      req = Rack::Request.new(env)
      begin
        status, headers, response = @app.call(env)
        resp = [status, headers, response]
        return *resp unless status == 404 && ::File.exists?(ISOLATION_FILE)
      rescue => e
        puts "Something weird happened: #{e}"
      end

      uri = URI.parse(req.path_info)
      file = (::File.extname(uri.path).empty?) ? "index.html" : ::File.basename(uri.path)
      file = "#{::File.basename(file, ::File.extname(file))}.*".force_encoding('utf-8')

      SafeYAML::OPTIONS[:default_mode] = :safe
      old_config = SafeYAML.load_file(ISOLATION_FILE)

      file_set = Set.new(old_config['include'])

      # Prevent loops.  If it's already in 'include' then we've gone through here before.
      return *resp if file_set.include?(file)

      old_config['include'] = file_set.add(file).to_a

      ::File.open(ISOLATION_FILE, 'w') do |f|
        YAML.dump(old_config, f)
      end

      response.close if response.respond_to?(:close)
      response = <<-PAGE.gsub(/^\s*/, '')
      <!DOCTYPE HTML>
      <html lang="en-US">
      <head>
        <meta charset="UTF-8">
        <title>Rendering #{req.path_info}</title>
      </head>
      <body>
        <h1>Hold on while I render that page for you!</h1>
      </body>
      PAGE

      headers ||= {}
      headers['Content-Length'] = response.length.to_s
      headers['Content-Type'] = 'text/html'
      headers['Connection'] = 'keep-alive'
      return [200, headers, response.split("\n")]
    end
  end
end


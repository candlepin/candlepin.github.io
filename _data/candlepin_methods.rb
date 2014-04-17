#!/usr/bin/env ruby
=begin
This file is used to mutate the candlepin_methods.json. It is in the _data directory
(instead of _plugins) because Jekyll simply calls a 'require' on all *.rb files
under _plugins and we perform the loading of this file dynamically in addition_json.rb.
=end

require 'nokogiri'
require_relative '../_plugins/mixins.rb'

module Mutate
  class Resource < Struct.new(:name, :methods)
    include Jekyll::Liquify
  end

  class CandlepinMethod < Struct.new(:url, :httpVerbs, :returns,
                                     :httpStatusCodes, :queryParams,
                                     :description, :deprecated)
    include Jekyll::Liquify
  end

  class QueryParameter < Struct.new(:name, :type)
    include Jekyll::Liquify
  end

  class StatusCode < Struct.new(:code, :description)
    include Jekyll::Liquify
  end

  def mutate(json)
    api = Hash.new { |hash, key| hash[key] = Resource.new(key, []) }
    json.each do |method|
      # Older version of ApiDoclet create bogus entries for abstract classes
      # and the like.
      if [method['url'], method['httpStatusCodes'], method['queryParams']].include?(nil)
        logger.warn("Missing API info:", method['method'])
        next
      end

      m = CandlepinMethod.new
      %w[url httpVerbs returns description].each do |attr|
        m.send("#{attr}=", method[attr] || '')
      end

      # Javadoc HTML is generally malformed. Let Nokogiri help fix it.
      m['description'] = Nokogiri::HTML.fragment(m['description']).to_s

      m.httpStatusCodes = method['httpStatusCodes'].each do |code|
        StatusCode.new(code['statusCode'], code['description'])
      end || []

      m.queryParams = method['queryParams'].each do |param|
        QueryParameter.new(param['name'], param['type'])
      end || []

      # !! will cast to boolean
      m.deprecated = !!method['deprecated']

      url = method['url']
      resource = "/#{url.split('/')[1]}"
      api[resource].methods << m
    end
    api.values
  end
end

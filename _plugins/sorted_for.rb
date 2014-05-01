#! /usr/bin/env ruby
# Courtesy of https://gist.github.com/mbland/3812259 and altered to allow nils.

require_relative 'mixins.rb'

class NilSortingArray < Array
  # sort_by with nils going at the end.
  def sort_by_with_nil!(meth=:to_s)
    # Break the collection into items that evaluate to nil and those that don't
    nulls, valids = self.partition do |i|
      res = (block_given?) ? yield(i) : i
      (res && res.send(meth)).nil?
    end

    valids.sort_by! do |i|
      res = (block_given?) ? yield(i) : i
      res.send(meth)
    end
    self.replace(valids + nulls)
  end
end

module Jekyll
  module SortedForImpl
    include LogCapable

    def render(context)
      sorted_collection = NilSortingArray.new(collection_to_sort(context))
      return if sorted_collection.empty?
      sort_attr = @attributes['sort_by']
      case_sensitive = @attributes['case_sensitive'] == 'true'
      i = sorted_collection.first

      if sort_attr != nil
        if i.to_liquid[sort_attr].instance_of? String and not case_sensitive
          sorted_collection.sort_by_with_nil!(:downcase) { |item| item.to_liquid[sort_attr] }
        else
          sorted_collection.sort_by_with_nil! { |item| item.to_liquid[sort_attr] }
        end
      else
        if i.instance_of? String and not case_sensitive
          sorted_collection.sort_by_with_nil!(:downcase)
        else
          sorted_collection.sort_by_with_nil!
        end
      end

      original_name = @collection_name
      result = nil
      context.stack do
        sorted_collection_name = "#{@collection_name}_sorted".sub('.', '_')
        context[sorted_collection_name] = sorted_collection
        @collection_name = sorted_collection_name
        result = super
        @collection_name = original_name
      end
      result
    end
  end

  class SortedForTag < Liquid::For
    include SortedForImpl

    def collection_to_sort(context)
      return context[@collection_name].dup
    end

    def end_tag
      'endsorted_for'
    end
  end

  class SortedKeysForTag < Liquid::For
    include SortedForImpl

    def collection_to_sort(context)
      return context[@collection_name].keys
    end

    def end_tag
      'endsorted_keys_for'
    end
  end
end

Liquid::Template.register_tag('sorted_for', Jekyll::SortedForTag)
Liquid::Template.register_tag('sorted_keys_for', Jekyll::SortedKeysForTag)

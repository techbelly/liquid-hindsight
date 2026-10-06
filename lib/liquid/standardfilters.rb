# frozen_string_literal: true

require 'cgi'
require 'base64'
require 'bigdecimal'
module Liquid
  module StandardFilters
    MAX_I32 = (1 << 31) - 1
    private_constant :MAX_I32

    supports_64bit_indices = begin
      [][1 << 33, 1 << 33]
      true
    end

    INDEX_RANGE = if supports_64bit_indices
      (-(1 << 63))..((1 << 63) - 1)
    else
      (-(1 << 31))..((1 << 31) - 1)
    end
    private_constant :INDEX_RANGE

    HTML_ESCAPE = {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '&quot;',
      "'" => '&#39;',
    }.freeze
    HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]+|(#\d+));)/
    STRIP_HTML_BLOCKS       = Regexp.union(
      %r{<script.*?</script>}m,
      /<!--.*?-->/m,
      %r{<style.*?</style>}m,
    )
    STRIP_HTML_TAGS = /<.*?>/m

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the size of a string or array.
    # @liquid_description
    #   The size of a string is the number of characters that the string includes. The size of an array is the number of items
    #   in the array.
    # @liquid_syntax variable | size
    # @liquid_return [number]
    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts a string to all lowercase characters.
    # @liquid_syntax string | downcase
    # @liquid_return [string]
    def downcase(input)
      Utils.to_s(input).downcase
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts a string to all uppercase characters.
    # @liquid_syntax string | upcase
    # @liquid_return [string]
    def upcase(input)
      Utils.to_s(input).upcase
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Escapes special characters in HTML, such as `<>`, `'`, and `&`, and converts characters into escape sequences. The filter doesn't effect characters within the string that don’t have a corresponding escape sequence.".
    # @liquid_syntax string | escape
    # @liquid_return [string]
    def escape(input)
      CGI.escapeHTML(Utils.to_s(input)) unless input.nil?
    end
    alias_method :h, :escape

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Escapes a string without changing characters that have already been escaped.
    # @liquid_syntax string | escape_once
    # @liquid_return [string]
    def escape_once(input)
      Utils.to_s(input).gsub(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Converts any URL-unsafe characters in a string to the
    #   [percent-encoded](https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding) equivalent.
    # @liquid_description
    #   > Note:
    #   > Spaces are converted to a `+` character, instead of a percent-encoded character.
    # @liquid_syntax string | url_encode
    # @liquid_return [string]
    def url_encode(input)
      CGI.escape(Utils.to_s(input)) unless input.nil?
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Decodes any [percent-encoded](https://developer.mozilla.org/en-US/docs/Glossary/percent-encoding) characters
    #   in a string.
    # @liquid_syntax string | url_decode
    # @liquid_return [string]
    def url_decode(input)
      return if input.nil?

      result = CGI.unescape(Utils.to_s(input))
      raise Liquid::ArgumentError, "invalid byte sequence in #{result.encoding}" unless result.valid_encoding?

      result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Encodes a string to [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_encode
    # @liquid_return [string]
    def base64_encode(input)
      Base64.strict_encode64(Utils.to_s(input))
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Encodes a string to URL-safe [Base64 format](https://developer.mozilla.org/en-US/docs/Glossary/Base64).
    # @liquid_syntax string | base64_url_safe_encode
    # @liquid_return [string]
    def base64_url_safe_encode(input)
      Base64.urlsafe_encode64(Utils.to_s(input))
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Splits a string into an array of substrings based on a given separator.
    # @liquid_syntax string | split: string
    # @liquid_return [array[string]]
    def split(input, pattern)
      pattern = Utils.to_s(pattern)
      input = Utils.to_s(input)
      input.split(pattern)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category string
    # @liquid_summary
    #   Strips all HTML tags from a string.
    # @liquid_syntax string | strip_html
    # @liquid_return [string]
    def strip_html(input)
      input = Utils.to_s(input)
      empty  = ''
      result = input.gsub(STRIP_HTML_BLOCKS, empty)
      result.gsub!(STRIP_HTML_TAGS, empty)
      result
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Sorts the items in an array in case-sensitive alphabetical, or numerical, order.
    # @liquid_syntax array | sort
    # @liquid_return [array[untyped]]
    def sort(input, property = nil)
      ary = InputIterator.new(input, context)

      return [] if ary.empty?

      if property.nil?
        ary.sort do |a, b|
          nil_safe_compare(a, b)
        end
      elsif ary.all? { |el| el.respond_to?(:[]) }
        begin
          ary.sort { |a, b| nil_safe_compare(a[property], b[property]) }
        rescue TypeError
          raise_property_error(property)
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Sorts the items in an array in case-insensitive alphabetical order.
    # @liquid_description
    #   > Caution:
    #   > You shouldn't use the `sort_natural` filter to sort numerical values. When comparing items an array, each item is converted to a
    #   > string, so sorting on numerical values can lead to unexpected results.
    # @liquid_syntax array | sort_natural
    # @liquid_return [array[untyped]]
    def sort_natural(input, property = nil)
      ary = InputIterator.new(input, context)

      return [] if ary.empty?

      if property.nil?
        ary.sort do |a, b|
          nil_safe_casecmp(a, b)
        end
      elsif ary.all? { |el| el.respond_to?(:[]) }
        begin
          ary.sort { |a, b| nil_safe_casecmp(a[property], b[property]) }
        rescue TypeError
          raise_property_error(property)
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Filters an array to include only items with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | where: string, string
    # @liquid_return [array[untyped]]
    def where(input, property, target_value = nil)
      filter_array(input, property, target_value) { |ary, &block| ary.select(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Tests if any item in an array has a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | has: string, string
    # @liquid_return [boolean]
    def has(input, property, target_value = nil)
      filter_array(input, property, target_value, false) { |ary, &block| ary.any?(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the first item in an array with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | find: string, string
    # @liquid_return [untyped]
    def find(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the index of the first item in an array with a specific property value.
    # @liquid_description
    #   This requires you to provide both the property name and the associated value.
    # @liquid_syntax array | find_index: string, string
    # @liquid_return [number]
    def find_index(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find_index(&block) }
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Removes any duplicate items in an array.
    # @liquid_syntax array | uniq
    # @liquid_return [array[untyped]]
    def uniq(input, property = nil)
      ary = InputIterator.new(input, context)

      if ary.empty? # The next two cases assume a non-empty array.
        []
      else
        ary.uniq do |item|
          item[property]
        rescue TypeError
          raise_property_error(property)
        rescue NoMethodError
          return nil unless item.respond_to?(:[])
          raise
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Reverses the order of the items in an array.
    # @liquid_syntax array | reverse
    # @liquid_return [array[untyped]]
    def reverse(input)
      ary = InputIterator.new(input, context)
      ary.reverse
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Creates an array of values from a specific property of the items in an array.
    # @liquid_syntax array | map: string
    # @liquid_return [array[untyped]]
    def map(input, property)
      InputIterator.new(input, context).map do |e|
        e = e.call if e.is_a?(Proc)

        if e.respond_to?(:[])
          r = e[property]
        end
      end
    rescue TypeError
      raise_property_error(property)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Removes any `nil` items from an array.
    # @liquid_syntax array | compact
    # @liquid_return [array[untyped]]
    def compact(input, property = nil)
      ary = InputIterator.new(input, context)

      if ary.empty? # The next two cases assume a non-empty array.
        []
      else
        ary.reject do |item|
          item[property].nil?
        rescue TypeError
          raise_property_error(property)
        rescue NoMethodError
          return nil unless item.respond_to?(:[])
          raise
        end
      end
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Concatenates (combines) two arrays.
    # @liquid_description
    #   > Note:
    #   > The `concat` filter won't filter out duplicates. If you want to remove duplicates, then you need to use the
    #   > [`uniq` filter](/docs/api/liquid/filters/uniq).
    # @liquid_syntax array | concat: array
    # @liquid_return [array[untyped]]
    def concat(input, array)
      unless array.respond_to?(:to_ary)
        raise ArgumentError, "concat filter requires an array argument"
      end
      InputIterator.new(input, context).concat(array)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the first item in an array.
    # @liquid_syntax array | first
    # @liquid_return [untyped]
    def first(array)
      # ActiveSupport returns "" for empty strings, not nil
      return array[0] || "" if array.is_a?(String)
      array.first if array.respond_to?(:first)
    end

    # @liquid_public_docs
    # @liquid_type filter
    # @liquid_category array
    # @liquid_summary
    #   Returns the last item in an array.
    # @liquid_syntax array | last
    # @liquid_return [untyped]
    def last(array)
      # ActiveSupport returns "" for empty strings, not nil
      return array[-1] || "" if array.is_a?(String)
      array.last if array.respond_to?(:last)
    end

    private

    attr_reader :context

    def filter_array(input, property, target_value, default_value = [], &block)
      ary = InputIterator.new(input, context)

      return default_value if ary.empty?

      block.call(ary) do |item|
        if target_value.nil?
          item[property]
        else
          item[property] == target_value
        end
      rescue TypeError
        raise_property_error(property)
      rescue NoMethodError
        return nil unless item.respond_to?(:[])
        raise
      end
    end

    def raise_property_error(property)
      raise Liquid::ArgumentError, "cannot select the property '#{Utils.to_s(property)}'"
    end

    def nil_safe_compare(a, b)
      result = a <=> b

      if result
        result
      elsif a.nil?
        1
      elsif b.nil?
        -1
      end
    end

    def nil_safe_casecmp(a, b)
      if !a.nil? && !b.nil?
        a.to_s.casecmp(b.to_s)
      elsif a.nil? && b.nil?
        0
      else
        a.nil? ? 1 : -1
      end
    end

    class InputIterator
      include Enumerable

      def initialize(input, context)
        @context = context
        @input   = if input.is_a?(Array)
          input.flatten
        elsif input.is_a?(Hash)
          [input]
        elsif input.is_a?(Enumerable)
          input
        else
          Array(input)
        end
      end

      def concat(args)
        to_a.concat(args)
      end

      def reverse
        reverse_each.to_a
      end

      def uniq(&block)
        to_a.uniq do |item|
          item = Utils.to_liquid_value(item)
          block ? yield(item) : item
        end
      end

      def empty?
        @input.each { return false }
        true
      end

      def each
        @input.each do |e|
          e = e.respond_to?(:to_liquid) ? e.to_liquid : e
          e.context = @context if e.respond_to?(:context=)
          yield(e)
        end
      end
    end
  end
end

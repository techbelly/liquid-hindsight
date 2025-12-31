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

    class << self
      def try_coerce_encoding(input, encoding:)
        original_encoding = input.encoding
        if input.encoding != encoding
          input.force_encoding(encoding)
          unless input.valid_encoding?
            input.force_encoding(original_encoding)
          end
        end
        input
      end
    end

    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    def downcase(input)
      Utils.to_s(input).downcase
    end

    def upcase(input)
      Utils.to_s(input).upcase
    end

    def capitalize(input)
      Utils.to_s(input).capitalize
    end

    def escape(input)
      CGI.escapeHTML(Utils.to_s(input)) unless input.nil?
    end
    alias_method :h, :escape

    def escape_once(input)
      Utils.to_s(input).gsub(HTML_ESCAPE_ONCE_REGEXP, HTML_ESCAPE)
    end

    def url_encode(input)
      CGI.escape(Utils.to_s(input)) unless input.nil?
    end

    def url_decode(input)
      return if input.nil?

      result = CGI.unescape(Utils.to_s(input))
      raise Liquid::ArgumentError, "invalid byte sequence in #{result.encoding}" unless result.valid_encoding?

      result
    end

    def base64_encode(input)
      Base64.strict_encode64(Utils.to_s(input))
    end

    def base64_decode(input)
      input = Utils.to_s(input)
      StandardFilters.try_coerce_encoding(Base64.strict_decode64(input), encoding: input.encoding)
    rescue ::ArgumentError
      raise Liquid::ArgumentError, "invalid base64 provided to base64_decode"
    end

    def base64_url_safe_encode(input)
      Base64.urlsafe_encode64(Utils.to_s(input))
    end

    def base64_url_safe_decode(input)
      input = Utils.to_s(input)
      StandardFilters.try_coerce_encoding(Base64.urlsafe_decode64(input), encoding: input.encoding)
    rescue ::ArgumentError
      raise Liquid::ArgumentError, "invalid base64 provided to base64_url_safe_decode"
    end

    def slice(input, offset, length = nil)
      offset = Utils.to_integer(offset)
      length = length ? Utils.to_integer(length) : 1

      begin
        if input.is_a?(Array)
          input.slice(offset, length) || []
        else
          Utils.to_s(input).slice(offset, length) || ''
        end
      rescue RangeError
        offset = offset.clamp(INDEX_RANGE)
        length = length.clamp(INDEX_RANGE)
        retry
      end
    end

    def truncate(input, length = 50, truncate_string = "...")
      return if input.nil?
      input_str = Utils.to_s(input)
      length    = Utils.to_integer(length)

      truncate_string_str = Utils.to_s(truncate_string)

      l = length - truncate_string_str.length
      l = 0 if l < 0

      input_str.length > length ? input_str[0...l].concat(truncate_string_str) : input_str
    end

    def truncatewords(input, words = 15, truncate_string = "...")
      return if input.nil?
      input = Utils.to_s(input)
      words = Utils.to_integer(words)
      words = 1 if words <= 0

      wordlist = begin
        input.split(" ", words + 1)
      rescue RangeError
        return input if words + 1 > MAX_I32
      end
      return input if wordlist.length <= words

      wordlist.pop
      truncate_string = Utils.to_s(truncate_string)
      wordlist.join(" ").concat(truncate_string)
    end

    def split(input, pattern)
      pattern = Utils.to_s(pattern)
      input = Utils.to_s(input)
      input.split(pattern)
    end

    def squish(input)
      return if input.nil?

      Utils.to_s(input).strip.gsub(/\s+/, ' ')
    end

    def strip(input)
      input = Utils.to_s(input)
      input.strip
    end

    def lstrip(input)
      input = Utils.to_s(input)
      input.lstrip
    end

    def strip_html(input)
      input = Utils.to_s(input)
      empty  = ''
      result = input.gsub(STRIP_HTML_BLOCKS, empty)
      result.gsub!(STRIP_HTML_TAGS, empty)
      result
    end

    def join(input, glue = ' ')
      glue = Utils.to_s(glue)
      InputIterator.new(input, context).join(glue)
    end

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

    def where(input, property, target_value = nil)
      filter_array(input, property, target_value) { |ary, &block| ary.select(&block) }
    end

    def reject(input, property, target_value = nil)
      filter_array(input, property, target_value) { |ary, &block| ary.reject(&block) }
    end

    def has(input, property, target_value = nil)
      filter_array(input, property, target_value, false) { |ary, &block| ary.any?(&block) }
    end

    def find(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find(&block) }
    end

    def find_index(input, property, target_value = nil)
      filter_array(input, property, target_value, nil) { |ary, &block| ary.find_index(&block) }
    end

    def uniq(input, property = nil)
      ary = InputIterator.new(input, context)

      if property.nil?
        ary.uniq
      elsif ary.empty?
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

    def reverse(input)
      ary = InputIterator.new(input, context)
      ary.reverse
    end

    def map(input, property)
      InputIterator.new(input, context).map do |e|
        e = e.call if e.is_a?(Proc)

        if e.respond_to?(:[])
          r = e[property]
          r.is_a?(Proc) ? r.call : r
        end
      end
    rescue TypeError
      raise_property_error(property)
    end

    def compact(input, property = nil)
      ary = InputIterator.new(input, context)

      if property.nil?
        ary.compact
      elsif ary.empty?
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

    def concat(input, array)
      unless array.respond_to?(:to_ary)
        raise ArgumentError, "concat filter requires an array argument"
      end
      InputIterator.new(input, context).concat(array)
    end

    def date(input, format)
      str_format = Utils.to_s(format)
      return input if str_format.empty?

      return input unless (date = Utils.to_date(input))

      date.strftime(str_format)
    end

    def first(array)
      return array[0] || "" if array.is_a?(String)
      array.first if array.respond_to?(:first)
    end

    def last(array)
      return array[-1] || "" if array.is_a?(String)
      array.last if array.respond_to?(:last)
    end

    def sum(input, property = nil)
      ary = InputIterator.new(input, context)
      return 0 if ary.empty?

      values_for_sum = ary.map do |item|
        if property.nil?
          item
        elsif item.respond_to?(:[])
          item[property]
        end
      rescue TypeError
        raise_property_error(property)
      end

      result = InputIterator.new(values_for_sum, context).sum do |item|
        Utils.to_number(item)
      end

      result.is_a?(BigDecimal) ? result.to_f : result
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

      def join(glue)
        first = true
        output = +""
        each do |item|
          if first
            first = false
          else
            output << glue
          end

          output << Liquid::Utils.to_s(item)
        end
        output
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

      def compact
        to_a.compact
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

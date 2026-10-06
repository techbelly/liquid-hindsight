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
  end
end

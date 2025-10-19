# frozen_string_literal: true

require 'cgi'
require 'base64'
require 'bigdecimal'
module Liquid
  module StandardFilters
    supports_64bit_indices = begin
      [][1 << 33, 1 << 33]
      true
    end

    HTML_ESCAPE = {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '&quot;',
      "'" => '&#39;',
    }.freeze
    HTML_ESCAPE_ONCE_REGEXP = /["><']|&(?!([a-zA-Z]+|(#\d+));)/

    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    def downcase(input)
      Utils.to_s(input).downcase
    end

    def upcase(input)
      Utils.to_s(input).upcase
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

    def base64_encode(input)
      Base64.strict_encode64(Utils.to_s(input))
    end

    def base64_url_safe_encode(input)
      Base64.urlsafe_encode64(Utils.to_s(input))
    end

    def split(input, pattern)
      pattern = Utils.to_s(pattern)
      input = Utils.to_s(input)
      input.split(pattern)
    end

    def first(array)
      return array[0] || "" if array.is_a?(String)
      array.first if array.respond_to?(:first)
    end

    def last(array)
      return array[-1] || "" if array.is_a?(String)
      array.last if array.respond_to?(:last)
    end

    private

    class InputIterator
      include Enumerable

      def empty?
        true
      end

      def each
      end
    end
  end
end

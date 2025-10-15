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

    def size(input)
      input.respond_to?(:size) ? input.size : 0
    end

    def first(array)
      return array[0] || "" if array.is_a?(String)
    end

    def last(array)
      return array[-1] || "" if array.is_a?(String)
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

# frozen_string_literal: true

module Liquid
  class RangeSlice
    def empty?
      @length.zero?
    end
  end
end

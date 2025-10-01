# frozen_string_literal: true

module Liquid
  class RangeSlice
    def empty?
      @length.zero?
    end

    def each
      return enum_for(:each) unless block_given?

      value = @first
    end
  end
end

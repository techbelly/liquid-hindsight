# frozen_string_literal: true

module Liquid
  class TablerowloopDrop < Drop
    def initialize(length, cols)
      @length = length
      @row    = 1
      @col    = 1
      @cols   = cols
      @index  = 0
    end

    attr_reader :length

    attr_reader :col

    def first
      @index == 0
    end

    def last
      @index == @length - 1
    end

    def col_last
      @col == @cols
    end

    protected

    def increment!
      @index += 1

      @col += 1
    end
  end
end

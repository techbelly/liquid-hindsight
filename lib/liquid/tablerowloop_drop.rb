# frozen_string_literal: true

module Liquid
  class TablerowloopDrop < Drop
    attr_reader :length

    def first
      @index == 0
    end

    def last
      @index == @length - 1
    end

    protected

    def increment!
      @index += 1

      if @col == @cols
        @col = 1
        @row += 1
      else
        @col += 1
      end
    end
  end
end

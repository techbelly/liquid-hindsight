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
  end
end

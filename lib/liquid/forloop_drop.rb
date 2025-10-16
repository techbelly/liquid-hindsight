# frozen_string_literal: true

module Liquid
  class ForloopDrop < Drop
    attr_reader :length

    attr_reader :name

    def first
      @index == 0
    end

    def last
      @index == @length - 1
    end

    protected
  end
end

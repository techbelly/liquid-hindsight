# frozen_string_literal: true

module Liquid
  class ForloopDrop < Drop
    def initialize(name, length, parentloop)
      @name       = name
      @length     = length
      @parentloop = parentloop
      @index      = 0
    end

    attr_reader :length

    attr_reader :name

    def first
      @index == 0
    end

    def last
      @index == @length - 1
    end

    protected

    def increment!
      @index += 1
    end
  end
end

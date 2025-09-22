# frozen_string_literal: true

module Liquid
  class Variable
    attr_accessor :name

    include ParserSwitching

    def disabled_tags
      []
    end

    private
  end
end

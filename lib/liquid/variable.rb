# frozen_string_literal: true

module Liquid
  class Variable
    attr_accessor :name, :line_number

    include ParserSwitching

    def disabled_tags
      []
    end

    private
  end
end

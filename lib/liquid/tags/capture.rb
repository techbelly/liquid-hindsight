# frozen_string_literal: true

module Liquid
  class Capture < Block
    include ParserSwitching

    Syntax = /(#{VariableSignature}+)/o

    def blank?
      true
    end
  end
end

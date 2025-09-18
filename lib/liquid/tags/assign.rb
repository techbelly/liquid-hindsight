# frozen_string_literal: true

module Liquid
  class Assign < Tag
    include ParserSwitching

    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/om

    def blank?
      true
    end

    private
  end
end

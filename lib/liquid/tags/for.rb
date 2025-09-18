# frozen_string_literal: true

module Liquid
  class For < Block
    Syntax = /\A(#{VariableSegment}+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/o

    protected

    private
  end
end

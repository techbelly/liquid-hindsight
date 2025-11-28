# frozen_string_literal: true

module Liquid
  class For < Block
    Syntax = /\A(#{VariableSegment}+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/o

    def initialize(tag_name, markup, options)
      super
      @from = @limit = nil
      parse_with_selected_parser(markup)
    end

    protected

    def strict_parse(markup)
      p = @parse_context.new_parser(markup)
    end

    private
  end
end

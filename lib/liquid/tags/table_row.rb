# frozen_string_literal: true

module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)

      @variable_name = p.consume(:id)

      unless p.id?("in")
        raise SyntaxError, options[:locale].t("errors.syntax.for_invalid_in")
      end
    end

    private
  end
end

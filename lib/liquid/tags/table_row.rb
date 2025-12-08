# frozen_string_literal: true

module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o
    ALLOWED_ATTRIBUTES = ['cols', 'limit', 'offset', 'range'].freeze

    attr_reader :collection_name, :attributes

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

      @collection_name = safe_parse_expression(p)

      p.consume?(:comma)

      @attributes = {}
      while p.look(:id)
        key = p.consume
        unless ALLOWED_ATTRIBUTES.include?(key)
          raise SyntaxError, options[:locale].t("errors.syntax.table_row_invalid_attribute", attribute: key)
        end
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end

    private
  end
end

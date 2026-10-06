# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name tablerow
  # @liquid_summary
  #   Generates HTML table rows for every item in an array.
  # @liquid_description
  #   The `tablerow` tag must be wrapped in HTML `<table>` and `</table>` tags.
  #
  #   > Tip:
  #   > Every `tablerow` loop has an associated [`tablerowloop` object](/docs/api/liquid/objects/tablerowloop) with information about the loop.
  # @liquid_syntax
  #   {% tablerow variable in array %}
  #     expression
  #   {% endtablerow %}
  # @liquid_syntax_keyword variable The current item in the array.
  # @liquid_syntax_keyword array The array to iterate over.
  # @liquid_syntax_keyword expression The expression to render.
  # @liquid_optional_param cols: [number] The number of columns that the table should have.
  # @liquid_optional_param limit: [number] The number of iterations to perform.
  # @liquid_optional_param offset: [number] The 1-based index to start iterating at.
  # @liquid_optional_param range [untyped] A custom numeric range to iterate over.
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o
    ALLOWED_ATTRIBUTES = ['cols', 'limit', 'offset', 'range'].freeze

    attr_reader :variable_name, :collection_name, :attributes

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

    private
  end
end

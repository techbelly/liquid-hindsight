# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category conditional
  # @liquid_name case
  # @liquid_summary
  #   Renders a specific expression depending on the value of a specific variable.
  # @liquid_syntax
  #   {% case variable %}
  #     {% when first_value %}
  #       first_expression
  #     {% when second_value %}
  #       second_expression
  #     {% else %}
  #       third_expression
  #   {% endcase %}
  # @liquid_syntax_keyword variable The name of the variable you want to base your case statement on.
  # @liquid_syntax_keyword first_value A specific value to check for.
  # @liquid_syntax_keyword second_value A specific value to check for.
  # @liquid_syntax_keyword first_expression An expression to be rendered when the variable's value matches `first_value`.
  # @liquid_syntax_keyword second_expression An expression to be rendered when the variable's value matches `second_value`.
  # @liquid_syntax_keyword third_expression An expression to be rendered when the variable's value has no match.
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    attr_reader :blocks, :left

    def nodelist
      @blocks.map(&:attachment)
    end

    private

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end
  end
end

# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category conditional
  # @liquid_name if
  # @liquid_summary
  #   Renders an expression if a specific condition is `true`.
  # @liquid_syntax
  #   {% if condition %}
  #     expression
  #   {% endif %}
  # @liquid_syntax_keyword condition The condition to evaluate.
  # @liquid_syntax_keyword expression The expression to render if the condition is met.
  class If < Block
    Syntax                  = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o
    ExpressionsAndOperators = /(?:\b(?:\s?and\s?|\s?or\s?)\b|(?:\s*(?!\b(?:\s?and\s?|\s?or\s?)\b)(?:#{QuotedFragment}|\S+)\s*)+)/o
    BOOLEAN_OPERATORS       = %w(and or).freeze

    attr_reader :blocks

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      push_block('if', markup)
    end

    ELSE_TAG_NAMES = ['elsif', 'else'].freeze
    private_constant :ELSE_TAG_NAMES

    private

    def push_block(tag, markup)
      block = if tag == 'else'
        ElseCondition.new
      else
        parse_with_selected_parser(markup)
      end
    end

    def strict_parse(markup)
      p = @parse_context.new_parser(markup)
    end
  end
end

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

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      parse_with_selected_parser(markup)
    end

    def parse(tokens)
      body = case_body = new_body
      body = @blocks.last.attachment while parse_body(body, tokens)
      @blocks.reverse_each do |condition|
        body = condition.attachment
        unless body.frozen?
          body.remove_blank_strings if blank?
          body.freeze
        end
      end
      case_body.freeze
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      case tag
      when 'when'
        record_when_condition(markup)
      else
        super
      end
    end

    private

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      if markup =~ Syntax
        @left = parse_expression(Regexp.last_match(1))
      end
    end

    def record_when_condition(markup)
      body = new_body

      parse_lax_when(markup, body)
    end

    def parse_lax_when(markup, body)
      while markup
        unless markup =~ WhenSyntax
          raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_when")
        end
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.left] + @node.blocks
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Include < Tag
    prepend Tag::Disableable

    FOR = 'for'
    SYNTAX = /(#{QuotedFragment}+)(\s+(with|#{FOR})\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o
    Syntax = SYNTAX

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def parse(_tokens)
    end

    alias_method :parse_context, :options
    private :parse_context

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      if markup =~ SYNTAX
        template_name = Regexp.last_match(1)
        with_or_for   = Regexp.last_match(3)
        variable_name = Regexp.last_match(4)

        @alias_name         = Regexp.last_match(6)
        @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
        @template_name_expr = parse_expression(template_name)
        @is_for_loop        = (with_or_for == FOR)
        @attributes         = {}

        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = parse_expression(value)
        end
      end
    end
  end
end

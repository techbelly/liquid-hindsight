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

    def for_loop?
      @is_for_loop
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)

      @template_name_expr = safe_parse_expression(p)
      with_or_for         = p.id?("for") || p.id?("with")
      @variable_name_expr = safe_parse_expression(p) if with_or_for
      @alias_name         = p.consume(:id) if p.id?("as")
      @is_for_loop        = (with_or_for == FOR)

      p.consume?(:comma)

      @attributes = {}
      while p.look(:id)
      end

      p.consume(:end_of_string)
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

# frozen_string_literal: true

module Liquid
  class Assign < Tag
    include ParserSwitching

    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/om

    def self.raise_syntax_error(parse_context)
      raise Liquid::SyntaxError, parse_context.locale.t('errors.syntax.assign')
    end

    def initialize(tag_name, markup, parse_context)
      super
      parse_with_selected_parser(markup)
    end

    def lax_parse(markup)
      self.class.raise_syntax_error(parse_context)
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def strict2_parse(markup)
      unless markup =~ Syntax
      end

      lhs = Regexp.last_match(1).strip
      rhs = Regexp.last_match(2)

      p = @parse_context.new_parser(lhs)
      @to = p.consume(:id)
      p.consume(:end_of_string)
    end

    def blank?
      true
    end

    private
  end
end

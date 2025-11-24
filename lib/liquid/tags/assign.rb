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

    def blank?
      true
    end

    private
  end
end

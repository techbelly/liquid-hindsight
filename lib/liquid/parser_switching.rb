# frozen_string_literal: true

module Liquid
  module ParserSwitching
    def strict_parse_with_error_mode_fallback(markup)
      return strict2_parse_with_error_context(markup) if strict2_mode?

      strict_parse_with_error_context(markup)
    rescue SyntaxError => e
      case parse_context.error_mode
      when :strict2
        raise
      when :strict
        raise
      end
      lax_parse(markup)
    end

    def strict2_mode?
      parse_context.error_mode == :strict2 || parse_context.error_mode == :rigid
    end

    private

    def strict2_parse_with_error_context(markup)
      strict2_parse(markup)
    rescue SyntaxError => e
      e.line_number    = line_number
      e.markup_context = markup_context(markup)
      raise e
    end

    def strict_parse_with_error_context(markup)
      strict_parse(markup)
    rescue SyntaxError => e
      e.line_number    = line_number
      e.markup_context = markup_context(markup)
      raise e
    end
  end
end

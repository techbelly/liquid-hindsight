# frozen_string_literal: true

module Liquid
  module ParserSwitching
    def strict_parse_with_error_mode_fallback(markup)
      return strict2_parse_with_error_context(markup) if strict2_mode?

      strict_parse_with_error_context(markup)
    end

    def strict2_mode?
      parse_context.error_mode == :strict2 || parse_context.error_mode == :rigid
    end

    private

    def strict_parse_with_error_context(markup)
      strict_parse(markup)
    end
  end
end

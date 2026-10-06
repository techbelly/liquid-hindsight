# frozen_string_literal: true

module Liquid
  module ParserSwitching
    # Do not use this.
    #
    # It's basically doing the same thing the {#parse_with_selected_parser},
    # except this will try the strict parser regardless of the error mode,
    # and fall back to the lax parser if the error mode is lax or warn,
    # except when in strict2 mode where it uses the strict2 parser.
    #
    # @deprecated Use {#parse_with_selected_parser} instead.
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

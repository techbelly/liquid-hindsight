# frozen_string_literal: true

module Liquid
  class Expression
    DOT = ".".ord
    ZERO = "0".ord
    NINE = "9".ord
    DASH = "-".ord

    RANGES_REGEX = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/
    INTEGER_REGEX = /\A(-?\d+)\z/

    class << self
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end

      def parse(markup, ss = StringScanner.new(""), cache = nil)
        return unless markup

        markup = markup.strip

        inner_parse(markup, ss, nil).freeze
      end

      def inner_parse(markup, ss, cache)
        if markup.start_with?("(") && markup.end_with?(")") && markup =~ RANGES_REGEX
        end

        if (num = parse_number(markup, ss))
          num
        else
          VariableLookup.parse(markup, ss, cache)
        end
      end

      def parse_number(markup, ss)
        case markup
        when INTEGER_REGEX
          return Integer(markup, 10)
        end

        ss.string = markup
        byte = ss.scan_byte

        return false if byte != DASH && (byte < ZERO || byte > NINE)
      end
    end
  end
end

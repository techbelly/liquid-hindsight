# frozen_string_literal: true

module Liquid
  class Expression
    DOT = ".".ord
    DASH = "-".ord

    class << self
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end
    end
  end
end

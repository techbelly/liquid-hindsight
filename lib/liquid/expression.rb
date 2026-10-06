# frozen_string_literal: true

module Liquid
  class Expression
    SELF = 'self'

    LITERALS = {
      nil => nil,
      'nil' => nil,
      'null' => nil,
      '' => nil,
      'true' => true,
      'false' => false,
      'blank' => '',
      'empty' => '',
      # in lax mode, minus sign can be a VariableLookup
      # For simplicity and performace, we treat it like a literal
      '-' => VariableLookup.parse("-", nil).freeze,
    }.freeze

    DOT = ".".ord
    ZERO = "0".ord
    NINE = "9".ord
    DASH = "-".ord

    # Use an atomic group (?>...) to avoid pathological backtracing from
    # malicious input as described in https://github.com/Shopify/liquid/issues/1357
    RANGES_REGEX = /\A\(\s*(?>(\S+)\s*\.\.)\s*(\S+)\s*\)\z/
    INTEGER_REGEX = /\A(-?\d+)\z/
    FLOAT_REGEX = /\A(-?\d+)\.\d+\z/

    class << self
      def safe_parse(parser, ss = StringScanner.new(""), cache = nil)
        parse(parser.expression, ss, cache)
      end
    end
  end
end

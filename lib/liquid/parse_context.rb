# frozen_string_literal: true

module Liquid
  class ParseContext
    attr_accessor :locale, :line_number, :trim_whitespace, :depth
    attr_reader :partial, :warnings, :error_mode, :environment

    def initialize(options = Const::EMPTY_HASH)
      @environment = options.fetch(:environment, Environment.default)
      @template_options = options ? options.dup : {}

      @locale   = @template_options[:locale] ||= I18n.new
      @warnings = []

      # constructing new StringScanner in Lexer, Tokenizer, etc is expensive
      # This StringScanner will be shared by all of them
      @string_scanner = StringScanner.new("")

      @expression_cache = if options[:expression_cache].nil?
        {}
      end

      self.depth   = 0
      self.partial = false
    end

    def [](option_key)
      @options[option_key]
    end

    def new_block_body
      Liquid::BlockBody.new
    end

    def new_parser(input)
      @string_scanner.string = input
      Parser.new(@string_scanner, reject_bare_brackets: @error_mode == :strict2 || @error_mode == :rigid)
    end

    def new_tokenizer(source, start_line_number: nil, for_liquid_tag: false)
      Tokenizer.new(
        source: source,
        string_scanner: @string_scanner,
        line_number: start_line_number,
        for_liquid_tag: for_liquid_tag,
      )
    end

    def safe_parse_expression(parser)
      Expression.safe_parse(parser, @string_scanner, @expression_cache)
    end

    def parse_expression(markup, safe: false)
      if !safe && @error_mode == :strict2
        # parse_expression is a widely used API. To maintain backward
        # compatibility while raising awareness about strict2 parser standards,
        # the safe flag supports API users make a deliberate decision.
        #
        # In strict2 mode, markup MUST come from a string returned by the parser
        # (e.g., parser.expression). We're not calling the parser here to
        # prevent redundant parser overhead.
        raise Liquid::InternalError, "unsafe parse_expression cannot be used in strict2 mode"
      end

      Expression.parse(markup, @string_scanner, @expression_cache)
    end

    def partial=(value)
      @partial = value
      @options = value ? partial_options : @template_options

      @error_mode = @options[:error_mode] || @environment.error_mode
    end
  end
end

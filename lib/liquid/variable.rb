# frozen_string_literal: true

module Liquid
  class Variable
    FilterMarkupRegex        = /#{FilterSeparator}\s*(.*)/om
    FilterParser             = /(?:\s+|#{QuotedFragment}|#{ArgumentSeparator})+/o
    FilterArgsRegex          = /(?:#{FilterArgumentSeparator}|#{ArgumentSeparator})\s*((?:\w+\s*\:\s*)?#{QuotedFragment})/o
    JustTagAttributes        = /\A#{TagAttributes}\z/o
    MarkupWithQuotedFragment = /(#{QuotedFragment})(.*)/om

    attr_accessor :filters, :name, :line_number
    attr_reader :parse_context
    alias_method :options, :parse_context

    include ParserSwitching

    def initialize(markup, parse_context)
      @markup        = markup
      @name          = nil
      @parse_context = parse_context
      @line_number   = parse_context.line_number

      strict_parse_with_error_mode_fallback(markup)
    end

    def raw
      @markup
    end

    def markup_context(markup)
      "in \"{{#{markup}}}\""
    end

    def lax_parse(markup)
      @filters = []
      return unless markup =~ MarkupWithQuotedFragment

      name_markup   = Regexp.last_match(1)
      filter_markup = Regexp.last_match(2)
      @name         = parse_context.parse_expression(name_markup)
      if filter_markup =~ FilterMarkupRegex
        filters = Regexp.last_match(1).scan(FilterParser)
        filters.each do |f|
          next unless f =~ /\w+/
          filtername = Regexp.last_match(0)
          filterargs = f.scan(FilterArgsRegex).flatten
          @filters << lax_parse_filter_expressions(filtername, filterargs)
        end
      end
    end

    def strict_parse(markup)
      @filters = []
      p = @parse_context.new_parser(markup)

      return if p.look(:end_of_string)

      @name = parse_context.safe_parse_expression(p)
      while p.consume?(:pipe)
        filtername = p.consume(:id)
        filterargs = p.consume?(:colon) ? parse_filterargs(p) : Const::EMPTY_ARRAY
        @filters << lax_parse_filter_expressions(filtername, filterargs)
      end
      p.consume(:end_of_string)
    end

    def parse_filterargs(p)
      filterargs = [p.argument]
      filterargs << p.argument while p.consume?(:comma)
      filterargs
    end

    def disabled_tags
      []
    end

    private

    def lax_parse_filter_expressions(filter_name, unparsed_args)
      filter_args  = []
      keyword_args = nil
      unparsed_args.each do |a|
        if (matches = a.match(JustTagAttributes))
          keyword_args           ||= {}
          keyword_args[matches[1]] = parse_context.parse_expression(matches[2])
        else
          filter_args << parse_context.parse_expression(a)
        end
      end
      result = [filter_name, filter_args]
      result << keyword_args if keyword_args
      result
    end
  end
end

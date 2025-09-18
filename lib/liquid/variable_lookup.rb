# frozen_string_literal: true

module Liquid
  class VariableLookup
    COMMAND_METHODS = ['size', 'first', 'last'].freeze

    def self.parse(markup, string_scanner = StringScanner.new(""), cache = nil)
      new(markup, string_scanner, cache)
    end

    def initialize(markup, string_scanner = StringScanner.new(""), cache = nil)
      lookups = markup.scan(VariableParser)

      name = lookups.shift
      if name&.start_with?('[') && name&.end_with?(']')
        name = Expression.parse(
          name[1..-2],
          string_scanner,
          cache,
        )
      end
      @name = name

      @lookups       = lookups
      @command_flags = 0

      @lookups.each_index do |i|
        lookup = lookups[i]
        if lookup&.start_with?('[') && lookup&.end_with?(']')
          lookups[i] = Expression.parse(
            lookup[1..-2],
            string_scanner,
            cache,
          )
        elsif COMMAND_METHODS.include?(lookup)
          @command_flags |= 1 << i
        end
      end
    end

    protected
  end
end

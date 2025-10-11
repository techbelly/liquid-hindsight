# frozen_string_literal: true

module Liquid
  class VariableLookup
    attr_reader :name, :lookups

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
      end
    end

    def ==(other)
      self.class == other.class && state == other.state
    end

    protected

    def state
      [@name, @lookups, @command_flags]
    end
  end
end

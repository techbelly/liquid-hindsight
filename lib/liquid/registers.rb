# frozen_string_literal: true

module Liquid
  class Registers
    attr_reader :static

    def initialize(registers = {})
      @static = registers.is_a?(Registers) ? registers.static : registers
      @changes = {}
    end

    def []=(key, value)
      @changes[key] = value
    end

    UNDEFINED = Object.new

    def key?(key)
      @changes.key?(key) || @static.key?(key)
    end
  end

  # Alias for backwards compatibility
  StaticRegisters = Registers
end

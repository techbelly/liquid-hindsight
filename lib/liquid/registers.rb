# frozen_string_literal: true

module Liquid
  class Registers
    attr_reader :static

    def initialize(registers = {})
      @static = registers.is_a?(Registers) ? registers.static : registers
      @changes = {}
    end

    UNDEFINED = Object.new
  end

  # Alias for backwards compatibility
  StaticRegisters = Registers
end

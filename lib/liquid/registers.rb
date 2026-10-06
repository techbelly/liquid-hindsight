# frozen_string_literal: true

module Liquid
  class Registers
    attr_reader :static

    UNDEFINED = Object.new
  end

  # Alias for backwards compatibility
  StaticRegisters = Registers
end

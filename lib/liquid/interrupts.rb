# frozen_string_literal: true

module Liquid
  class Interrupt
    attr_reader :message

    def initialize(message = nil)
      @message = message || "interrupt"
    end
  end

  class BreakInterrupt < Interrupt; end
  class ContinueInterrupt < Interrupt; end
end

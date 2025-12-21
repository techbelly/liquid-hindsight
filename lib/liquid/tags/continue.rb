# frozen_string_literal: true

module Liquid
  class Continue < Tag
    INTERRUPT = ContinueInterrupt.new.freeze
  end
end

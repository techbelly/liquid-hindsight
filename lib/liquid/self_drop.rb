# frozen_string_literal: true

module Liquid
  class SelfDrop < Drop
    def [](key)
      @self_context.find_variable(key)
    rescue UndefinedVariable
      nil
    end

    def to_liquid
      self
    end

    alias_method :eql?, :==

    protected

    undef context=
  end
end

# frozen_string_literal: true

module Liquid
  class SelfDrop < Drop
    def to_liquid
      self
    end

    alias_method :eql?, :==

    protected

    undef context=
  end
end

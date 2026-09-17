# frozen_string_literal: true

module Liquid
  class SelfDrop < Drop
    def initialize(self_context)
      super()
      @self_context = self_context
    end

    def [](key)
      @self_context.find_variable(key)
    rescue UndefinedVariable
      nil
    end

    def key?(key)
      @self_context.variable_defined?(key)
    end

    def to_liquid
      self
    end

    def ==(other)
      other.is_a?(SelfDrop) && other.self_context.equal?(@self_context)
    end

    alias_method :eql?, :==

    def hash
      @self_context.object_id.hash
    end

    protected

    attr_reader :self_context

    undef context=
  end
end

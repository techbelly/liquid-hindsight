# frozen_string_literal: true

module Liquid
  class Template
    attr_accessor :root, :name

    class << self
      def tags
        Environment.default.tags
      end
    end

    def initialize(environment: Environment.default)
      @environment = environment
      @rethrow_errors  = false
      @resource_limits = ResourceLimits.new(environment.default_resource_limits)
    end

    private
  end
end

# frozen_string_literal: true

module Liquid
  class Context
    attr_reader :scopes, :registers
    attr_accessor :exception_renderer, :partial, :global_filter, :strict_variables

    def initialize(environments = {}, outer_scope = {}, registers = {}, rethrow_errors = false, resource_limits = nil, static_environments = {}, environment = Environment.default)
      @environment = environment
      @environments = [environments]
      @environments.flatten!

      @static_environments = [static_environments].flatten(1).freeze
      @scopes              = [outer_scope || {}]
      @registers           = registers.is_a?(Registers) ? registers : Registers.new(registers)
      @errors              = []
      @partial             = false
      @strict_variables    = false
      @resource_limits     = resource_limits || ResourceLimits.new(environment.default_resource_limits)
      @base_scope_depth    = 0
      @interrupts          = []
      @filters             = []
      @global_filter       = nil
      @disabled_tags       = {}

      @string_scanner = StringScanner.new("")

      @registers.static[:cached_partials] ||= {}
      @registers.static[:file_system] ||= environment.file_system
      @registers.static[:template_factory] ||= Liquid::TemplateFactory.new

      self.exception_renderer = environment.exception_renderer

      yield self if block_given?

      squash_instance_assigns_with_environments
    end

    def apply_global_filter(obj)
      global_filter.nil? ? obj : global_filter.call(obj)
    end

    def interrupt?
      !@interrupts.empty?
    end

    protected

    private

    def squash_instance_assigns_with_environments
      @scopes.last.each_key do |k|
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Context
    attr_reader :scopes, :errors, :registers, :environments, :resource_limits, :static_environments
    attr_accessor :exception_renderer, :template_name, :partial, :global_filter, :strict_variables, :strict_filters, :environment

    def self.build(environment: Environment.default, environments: {}, outer_scope: {}, registers: {}, rethrow_errors: false, resource_limits: nil, static_environments: {}, &block)
      new(environments, outer_scope, registers, rethrow_errors, resource_limits, static_environments, environment, &block)
    end

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
      if rethrow_errors
        self.exception_renderer = Liquid::RAISE_EXCEPTION_LAMBDA
      end

      yield self if block_given?

      squash_instance_assigns_with_environments
    end

    def warnings
      @warnings ||= []
    end

    def strainer
      @strainer ||= @environment.create_strainer(self, @filters)
    end

    def add_filters(filters)
      filters = [filters].flatten.compact
      @filters += filters
      @strainer = nil
    end

    def apply_global_filter(obj)
      global_filter.nil? ? obj : global_filter.call(obj)
    end

    def interrupt?
      !@interrupts.empty?
    end

    def push_interrupt(e)
      @interrupts.push(e)
    end

    def handle_error(e, line_number = nil)
      e = internal_error unless e.is_a?(Liquid::Error)
      e.template_name ||= template_name
      e.line_number   ||= line_number
      errors.push(e)
      exception_renderer.call(e).to_s
    end

    def invoke(method, *args)
      strainer.invoke(method, *args).to_liquid
    end

    def push(new_scope = {})
      @scopes.unshift(new_scope)
      check_overflow
    end

    def merge(new_scopes)
      @scopes[0].merge!(new_scopes)
    end

    def pop
      raise ContextError if @scopes.size == 1
      @scopes.shift
    end

    def stack(new_scope = {})
      push(new_scope)
      yield
    ensure
      pop
    end

    def new_isolated_subcontext
      check_overflow

      self.class.build(
        environment: @environment,
        resource_limits: resource_limits,
        static_environments: static_environments,
        registers: Registers.new(registers),
      ).tap do |subcontext|
        subcontext.base_scope_depth   = base_scope_depth + 1
        subcontext.exception_renderer = exception_renderer
        subcontext.filters  = @filters
        subcontext.strainer = nil
        subcontext.errors   = errors
        subcontext.warnings = warnings
        subcontext.disabled_tags = @disabled_tags
      end
    end

    def []=(key, value)
      @scopes[0][key] = value
    end

    def [](expression)
      evaluate(Expression.parse(expression, @string_scanner))
    end

    def key?(key)
      find_variable(key, raise_on_not_found: false) != nil
    end

    def variable_defined?(key)
      @scopes.any? { |s| s.key?(key) } ||
        @environments.any? { |e| e.key?(key) } ||
        @static_environments.any? { |e| e.key?(key) }
    end

    def evaluate(object)
      object.respond_to?(:evaluate) ? object.evaluate(self) : object
    end

    def find_variable(key, raise_on_not_found: true)
      index = @scopes.find_index { |s| s.key?(key) }

      fallback_to_self_drop = key == Expression::SELF && index.nil?

      variable = if index
        lookup_and_evaluate(@scopes[index], key, raise_on_not_found: raise_on_not_found)
      else
        try_variable_find_in_environments(
          key,
          raise_on_not_found: raise_on_not_found && !fallback_to_self_drop,
        )
      end

      return @self_drop ||= SelfDrop.new(self) if fallback_to_self_drop && variable.nil?

      variable.context = self if variable.respond_to?(:context=)

      liquid_variable = variable.to_liquid

      liquid_variable.context = self if variable != liquid_variable && liquid_variable.respond_to?(:context=)

      liquid_variable
    end

    def lookup_and_evaluate(obj, key, raise_on_not_found: true)
      if @strict_variables && raise_on_not_found && obj.respond_to?(:key?) && !obj.key?(key)
        raise Liquid::UndefinedVariable, "undefined variable #{key}"
      end

      value = obj[key]

      if value.is_a?(Proc) && obj.respond_to?(:[]=)
        obj[key] = value.arity == 0 ? value.call : value.call(self)
      else
        value
      end
    end

    def with_disabled_tags(tag_names)
      tag_names.each do |name|
        @disabled_tags[name] = @disabled_tags.fetch(name, 0) + 1
      end
      yield
    ensure
      tag_names.each do |name|
        @disabled_tags[name] -= 1
      end
    end

    def tag_disabled?(tag_name)
      @disabled_tags.fetch(tag_name, 0) > 0
    end

    protected

    attr_writer :base_scope_depth, :warnings, :errors, :strainer, :filters, :disabled_tags

    private

    attr_reader :base_scope_depth

    def try_variable_find_in_environments(key, raise_on_not_found:)
      @environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
      end
      @static_environments.each do |environment|
        found_variable = lookup_and_evaluate(environment, key, raise_on_not_found: raise_on_not_found)
        if !found_variable.nil? || @strict_variables && raise_on_not_found
          return found_variable
        end
      end
      nil
    end

    def check_overflow
      raise StackLevelError, "Nesting too deep" if overflow?
    end

    def overflow?
      base_scope_depth + @scopes.length > Block::MAX_DEPTH
    end

    def internal_error
      raise Liquid::InternalError, 'internal'
    rescue Liquid::InternalError => exc
      exc
    end

    def squash_instance_assigns_with_environments
      @scopes.last.each_key do |k|
        @environments.each do |env|
          if env.key?(k)
            scopes.last[k] = lookup_and_evaluate(env, k)
            break
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  # Context keeps the variable stack and resolves variables, as well as keywords
  #
  #   context['variable'] = 'testing'
  #   context['variable'] #=> 'testing'
  #   context['true']     #=> true
  #   context['10.2232']  #=> 10.2232
  #
  #   context.stack do
  #      context['bob'] = 'bobsen'
  #   end
  #
  #   context['bob']  #=> nil  class Context
  class Context
    attr_reader :scopes, :errors, :registers, :environments, :resource_limits, :static_registers, :static_environments
    attr_accessor :exception_renderer, :template_name, :partial, :global_filter, :strict_variables, :strict_filters, :environment

    # rubocop:disable Metrics/ParameterLists

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

      # Instead of constructing new StringScanner objects for each Expression parse,
      # we recycle the same one.
      @string_scanner = StringScanner.new("")

      @registers.static[:cached_partials] ||= {}
      @registers.static[:file_system] ||= environment.file_system
      @registers.static[:template_factory] ||= Liquid::TemplateFactory.new

      self.exception_renderer = environment.exception_renderer

      yield self if block_given?

      # Do this last, since it could result in this object being passed to a Proc in the environment
      squash_instance_assigns_with_environments
    end
    # rubocop:enable Metrics/ParameterLists

    def strainer
      @strainer ||= @environment.create_strainer(self, @filters)
    end

    def apply_global_filter(obj)
      global_filter.nil? ? obj : global_filter.call(obj)
    end

    # are there any not handled interrupts?
    def interrupt?
      !@interrupts.empty?
    end

    # Push new local scope on the stack. use <tt>Context#stack</tt> instead
    def push(new_scope = {})
      @scopes.unshift(new_scope)
      check_overflow
    end

    # Merge a hash of variables in the current local scope
    def merge(new_scopes)
      @scopes[0].merge!(new_scopes)
    end

    # Pop from the stack. use <tt>Context#stack</tt> instead
    def pop
      raise ContextError if @scopes.size == 1
      @scopes.shift
    end

    # Only allow String, Numeric, Hash, Array, Proc, Boolean or <tt>Liquid::Drop</tt>
    def []=(key, value)
      @scopes[0][key] = value
    end

    # Look up variable, either resolve directly after considering the name. We can directly handle
    # Strings, digits, floats and booleans (true,false).
    # If no match is made we lookup the variable in the current scope and
    # later move up to the parent blocks to see if we can resolve the variable somewhere up the tree.
    # Some special keywords return symbols. Those symbols are to be called on the rhs object in expressions
    #
    # Example:
    #   products == empty #=> products.empty?
    def [](expression)
      evaluate(Expression.parse(expression, @string_scanner))
    end

    def key?(key)
      find_variable(key, raise_on_not_found: false) != nil
    end

    def evaluate(object)
      object.respond_to?(:evaluate) ? object.evaluate(self) : object
    end

    # Fetches an object starting at the local scope and then moving up the hierachy
    def find_variable(key, raise_on_not_found: true)
      # This was changed from find() to find_index() because this is a very hot
      # path and find_index() is optimized in MRI to reduce object allocation
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

      # `self` resolves to a SelfDrop (enabling `self['var']` lookups),
      # but only after the normal environment lookup doesn't find a value.
      return @self_drop ||= SelfDrop.new(self) if fallback_to_self_drop && variable.nil?

      # update variable's context before invoking #to_liquid
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
      end
    end

    def check_overflow
      raise StackLevelError, "Nesting too deep" if overflow?
    end

    def overflow?
      base_scope_depth + @scopes.length > Block::MAX_DEPTH
    end

    def squash_instance_assigns_with_environments
      @scopes.last.each_key do |k|
      end
    end # squash_instance_assigns_with_environments
  end # Context
end # Liquid

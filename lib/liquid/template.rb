# frozen_string_literal: true

module Liquid
  class Template
    attr_accessor :root, :name
    attr_reader :resource_limits, :warnings

    attr_reader :profiler

    class << self
      def error_mode
        Environment.default.error_mode
      end

      def file_system
        Environment.default.file_system
      end

      def tags
        Environment.default.tags
      end

      def parse(source, options = {})
        environment = options[:environment] || Environment.default
        new(environment: environment).parse(source, options)
      end
    end

    def initialize(environment: Environment.default)
      @environment = environment
      @rethrow_errors  = false
      @resource_limits = ResourceLimits.new(environment.default_resource_limits)
    end

    def parse(source, options = {})
      parse_context = configure_options(options)
      source = source.to_s.to_str

      unless source.valid_encoding?
        raise TemplateEncodingError, parse_context.locale.t("errors.syntax.invalid_template_encoding")
      end

      tokenizer     = parse_context.new_tokenizer(source, start_line_number: @line_numbers && 1)
      @root         = Document.parse(tokenizer, parse_context)
      self
    end

    def registers
      @registers ||= {}
    end

    def assigns
      @assigns ||= {}
    end

    def instance_assigns
      @instance_assigns ||= {}
    end

    def render(*args)
      return '' if @root.nil?

      context = case args.first
      when Liquid::Context
        c = args.shift

        c
      when Liquid::Drop
      when Hash
        Context.new([args.shift, assigns], instance_assigns, registers, @rethrow_errors, @resource_limits, {}, @environment)
      when nil
        Context.new(assigns, instance_assigns, registers, @rethrow_errors, @resource_limits, {}, @environment)
      else
        raise ArgumentError, "Expected Hash or Liquid::Context as parameter"
      end

      output = nil

      context.resource_limits.reset

      if @profiling && context.profiler.nil?
      end

      context.template_name ||= name

      previous_error_mode = context.registers.static[:template_error_mode]
      context.registers.static[:template_error_mode] = @error_mode

      begin
        @root.render_to_output_buffer(context, output || +'')
      rescue Liquid::MemoryError => e
        context.handle_error(e)
      ensure
        context.registers.static.delete(:template_error_mode)
        @errors = context.errors
      end
    end

    def render!(*args)
      @rethrow_errors = true
      render(*args)
    end

    private

    def configure_options(options)
      if (profiling = options[:profile])
      end

      @options      = options
      @profiling    = profiling
      @line_numbers = options[:line_numbers] || @profiling
      parse_context = if options.is_a?(ParseContext)
        options
      else
        opts = options.key?(:environment) ? options : options.merge(environment: @environment)
        ParseContext.new(opts)
      end

      @warnings = parse_context.warnings
      @error_mode = parse_context.error_mode
      parse_context
    end
  end
end

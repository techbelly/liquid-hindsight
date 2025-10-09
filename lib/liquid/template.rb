# frozen_string_literal: true

module Liquid
  class Template
    attr_accessor :root, :name
    attr_reader :warnings

    class << self
      def error_mode
        Environment.default.error_mode
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

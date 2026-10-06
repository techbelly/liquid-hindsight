# frozen_string_literal: true

module Liquid
  # The Environment is the container for all configuration options of Liquid, such as
  # the registered tags, filters, and the default error mode.
  class Environment
    # The default error mode for all templates. This can be overridden on a
    # per-template basis.
    attr_accessor :error_mode

    # The tags that are available to use in the template.
    attr_accessor :tags

    # The strainer template which is used to store filters that are available to
    # use in templates.
    attr_accessor :strainer_template

    # The exception renderer that is used to render exceptions that are raised
    # when rendering a template
    attr_accessor :exception_renderer

    # The default file system that is used to load templates from.
    attr_accessor :file_system

    # The default resource limits that are used to limit the resources that a
    # template can consume.
    attr_accessor :default_resource_limits

    class << self
      # Returns the default environment instance.
      #
      # @return [Environment] The default environment instance.
      def default
        @default ||= new
      end

      # Sets the default environment instance for the duration of the block
      #
      # @param environment [Environment] The environment instance to use as the default for the
      #   duration of the block.
      # @yield
      # @return [Object] The return value of the block.
      def dangerously_override(environment)
        original_default = @default
        @default = environment
        yield
      ensure
        @default = original_default
      end
    end

    # Initializes a new environment instance.
    # @api private
    def initialize
      @tags = Tags::STANDARD_TAGS.dup
      @error_mode = :lax
      @strainer_template = Class.new(StrainerTemplate).tap do |klass|
        klass.add_filter(StandardFilters)
      end
      @exception_renderer = ->(exception) { exception }
      @file_system = BlankFileSystem.new
      @default_resource_limits = Const::EMPTY_HASH
      @strainer_template_class_cache = {}
    end

    # Registers a new tag with the environment.
    #
    # @param name [String] The name of the tag.
    # @param klass [Liquid::Tag] The class that implements the tag.
    # @return [void]
    def register_tag(name, klass)
      @tags[name] = klass
    end

    # Creates a new strainer instance with the given filters, caching the result
    # for faster lookup.
    #
    # @param context [Liquid::Context] The context that the strainer will be
    #   used in.
    # @param filters [Array<Module>] The filters that the strainer will have
    #   access to.
    # @return [Liquid::Strainer] The new strainer instance.
    def create_strainer(context, filters = Const::EMPTY_ARRAY)
      return @strainer_template.new(context) if filters.empty?
    end
  end
end

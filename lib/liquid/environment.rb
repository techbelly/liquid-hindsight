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
  end
end

# frozen_string_literal: true

module Liquid
  class Environment
    attr_accessor :error_mode

    attr_accessor :tags

    attr_accessor :exception_renderer

    attr_accessor :file_system

    attr_reader :default_resource_limits

    class << self
      def build(tags: nil, file_system: nil, error_mode: nil, exception_renderer: nil)
        ret = new
        ret.tags = tags if tags
        ret.file_system = file_system if file_system
        ret.error_mode = error_mode if error_mode
        ret.exception_renderer = exception_renderer if exception_renderer
        yield ret if block_given?
        ret.freeze
      end

      def default
        @default ||= new
      end

      def dangerously_override(environment)
        original_default = @default
        @default = environment
        yield
      ensure
        @default = original_default
      end
    end

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

    def register_tag(name, klass)
      @tags[name] = klass
    end

    def register_filter(filter)
      @strainer_template_class_cache.clear
      @strainer_template.add_filter(filter)
    end

    def create_strainer(context, filters = Const::EMPTY_ARRAY)
      return @strainer_template.new(context) if filters.empty?

      strainer_template = @strainer_template_class_cache[filters] ||= begin
        klass = Class.new(@strainer_template)
        filters.each { |f| klass.add_filter(f) }
        klass
      end

      strainer_template.new(context)
    end

    def freeze
      @tags.freeze
      super
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Environment
    attr_accessor :error_mode

    attr_reader :tags

    attr_reader :default_resource_limits

    class << self
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
  end
end

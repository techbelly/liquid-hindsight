# frozen_string_literal: true

require 'liquid/tag/disabler'
require 'liquid/tag/disableable'

module Liquid
  class Tag
    attr_reader :nodelist, :tag_name, :line_number, :parse_context
    alias_method :options, :parse_context
    include ParserSwitching

    class << self
      def disable_tags(*tag_names)
        tag_names += disabled_tags
        define_singleton_method(:disabled_tags) { tag_names }
        prepend(Disabler)
      end

      private :new

      protected

      def disabled_tags
        []
      end
    end

    def parse(_tokens)
    end

    private
  end
end

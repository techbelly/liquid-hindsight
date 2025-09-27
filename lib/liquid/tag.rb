# frozen_string_literal: true

require 'liquid/tag/disabler'
require 'liquid/tag/disableable'

module Liquid
  class Tag
    attr_reader :line_number
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

    def blank?
      false
    end

    private
  end
end

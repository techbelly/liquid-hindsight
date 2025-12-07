# frozen_string_literal: true

module Liquid
  class Echo < Tag
    attr_reader :variable

    def initialize(tag_name, markup, parse_context)
      super
      @variable = Variable.new(markup, parse_context)
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.variable]
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Echo < Tag
    def initialize(tag_name, markup, parse_context)
      super
      @variable = Variable.new(markup, parse_context)
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end
  end
end

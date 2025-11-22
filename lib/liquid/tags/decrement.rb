# frozen_string_literal: true

module Liquid
  class Decrement < Tag
    include ParserSwitching

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup.strip)
      @variable_name = p.consume(:id)
      p.consume(:end_of_string)
    end
  end
end

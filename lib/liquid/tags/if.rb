# frozen_string_literal: true

module Liquid
  class If < Block
    Syntax                  = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      push_block('if', markup)
    end

    private

    def push_block(tag, markup)
      block = if tag == 'else'
        ElseCondition.new
      else
        parse_with_selected_parser(markup)
      end
    end

    def strict_parse(markup)
      p = @parse_context.new_parser(markup)
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Increment < Tag
    include ParserSwitching

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def lax_parse(markup)
      @variable_name = markup.strip
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup.strip)
      @variable_name = p.consume(:id)
      p.consume(:end_of_string)
    end

    def render_to_output_buffer(context, output)
      counter_environment = context.environments.first
      value = counter_environment[@variable_name] || 0
      counter_environment[@variable_name] = value + 1

      output << value.to_s
      output
    end
  end
end

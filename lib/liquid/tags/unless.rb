# frozen_string_literal: true

require_relative 'if'

module Liquid
  class Unless < If
    def render_to_output_buffer(context, output)
      first_block = @blocks.first
      result = Liquid::Utils.to_liquid_value(
        first_block.evaluate(context),
      )

      unless result
        return first_block.attachment.render_to_output_buffer(context, output)
      end
    end
  end
end

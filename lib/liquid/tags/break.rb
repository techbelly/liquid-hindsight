# frozen_string_literal: true

module Liquid
  class Break < Tag
    INTERRUPT = BreakInterrupt.new.freeze

    def render_to_output_buffer(context, output)
      context.push_interrupt(INTERRUPT)
      output
    end
  end
end

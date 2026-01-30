# frozen_string_literal: true

module Liquid
  class Continue < Tag
    INTERRUPT = ContinueInterrupt.new.freeze

    def render_to_output_buffer(context, output)
      context.push_interrupt(INTERRUPT)
      output
    end
  end
end

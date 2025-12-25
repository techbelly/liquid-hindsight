# frozen_string_literal: true

module Liquid
  class Tag
    module Disableable
      def render_to_output_buffer(context, output)
        if context.tag_disabled?(tag_name)
        end
        super
      end
    end
  end
end

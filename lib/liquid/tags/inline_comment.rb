# frozen_string_literal: true

module Liquid
  class InlineComment < Tag
    def initialize(tag_name, markup, options)
      super

      if markup.match?(/\n\s*[^#\s]/)
        raise SyntaxError, options[:locale].t("errors.syntax.inline_comment_invalid")
      end
    end

    def render_to_output_buffer(_context, output)
      output
    end

    def blank?
      true
    end
  end
end

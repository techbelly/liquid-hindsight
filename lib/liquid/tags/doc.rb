# frozen_string_literal: true

module Liquid
  class Doc < Block
    NO_UNEXPECTED_ARGS = /\A\s*\z/

    def initialize(tag_name, markup, parse_context)
      super
      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def parse(tokens)
      @body = +""

      while (token = tokens.shift)
        tag_name = token =~ BlockBody::FullTokenPossiblyInvalid && Regexp.last_match(2)

        raise_nested_doc_error if tag_name == @tag_name

        if tag_name == block_delimiter
          parse_context.trim_whitespace = (token[-3] == WhitespaceControl)
          @body << Regexp.last_match(1) if Regexp.last_match(1) != ""
          return
        end
        @body << token unless token.empty?
      end

      raise_tag_never_closed(block_name)
    end

    def render_to_output_buffer(_context, output)
      output
    end

    def blank?
      @body.empty?
    end

    def nodelist
      [@body]
    end

    private

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless NO_UNEXPECTED_ARGS.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.block_tag_unexpected_args", tag: tag_name)
      end
    end

    def raise_nested_doc_error
      raise SyntaxError, parse_context.locale.t("errors.syntax.doc_invalid_nested")
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Raw < Block
    Syntax = /\A\s*\z/

    def initialize(tag_name, markup, parse_context)
      super

      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def parse(tokens)
      @body = +''
      while (token = tokens.shift)
        if token =~ BlockBody::FullTokenPossiblyInvalid && block_delimiter == Regexp.last_match(2)
        end
        @body << token unless token.empty?
      end

      raise_tag_never_closed(block_name)
    end

    def nodelist
      [@body]
    end

    def blank?
      @body.empty?
    end

    protected

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless Syntax.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.tag_unexpected_args", tag: tag_name)
      end
    end
  end
end

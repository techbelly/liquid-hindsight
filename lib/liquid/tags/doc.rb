# frozen_string_literal: true

module Liquid
  class Doc < Block
    NO_UNEXPECTED_ARGS = /\A\s*\z/

    def initialize(tag_name, markup, parse_context)
      super
      ensure_valid_markup(tag_name, markup, parse_context)
    end

    def blank?
      @body.empty?
    end

    private

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless NO_UNEXPECTED_ARGS.match?(markup)
        raise SyntaxError, parse_context.locale.t("errors.syntax.block_tag_unexpected_args", tag: tag_name)
      end
    end
  end
end

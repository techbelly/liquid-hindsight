# frozen_string_literal: true

module Liquid
  class Block < Tag
    MAX_DEPTH = 100

    def initialize(tag_name, markup, options)
      super
      @blank = true
    end

    def raise_tag_never_closed(block_name)
      raise SyntaxError, parse_context.locale.t("errors.syntax.tag_never_closed", block_name: block_name)
    end

    def block_name
      @tag_name
    end

    def block_delimiter
      @block_delimiter ||= "end#{block_name}"
    end

    private
  end
end

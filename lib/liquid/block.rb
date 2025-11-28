# frozen_string_literal: true

module Liquid
  class Block < Tag
    MAX_DEPTH = 100

    def initialize(tag_name, markup, options)
      super
      @blank = true
    end

    def parse(tokens)
      @body = new_body
      while parse_body(@body, tokens)
      end
      @body.freeze
    end

    def blank?
      @blank
    end

    def unknown_tag(tag_name, _markup, _tokenizer)
      Block.raise_unknown_tag(tag_name, block_name, block_delimiter, parse_context)
    end

    def self.raise_unknown_tag(tag, block_name, block_delimiter, parse_context)
      raise SyntaxError, parse_context.locale.t("errors.syntax.unknown_tag", tag: tag)
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

    def new_body
      parse_context.new_block_body
    end

    def parse_body(body, tokens)
      if parse_context.depth >= MAX_DEPTH
        raise StackLevelError, "Nesting too deep"
      end
      parse_context.depth += 1
      begin
        body.parse(tokens, parse_context) do |end_tag_name, end_tag_params|
          @blank &&= body.blank?

          return false if end_tag_name == block_delimiter
          raise_tag_never_closed(block_name) unless end_tag_name

          unknown_tag(end_tag_name, end_tag_params, tokens)
        end
      ensure
        parse_context.depth -= 1
      end
    end
  end
end

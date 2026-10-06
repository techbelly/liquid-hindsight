# frozen_string_literal: true

module Liquid
  class Document
    def self.parse(tokens, parse_context)
      doc = new(parse_context)
      doc.parse(tokens, parse_context)
    end

    attr_reader :parse_context, :body

    def initialize(parse_context)
      @parse_context = parse_context
      @body = new_body
    end

    def parse(tokenizer, parse_context)
      while parse_body(tokenizer)
      end
    rescue SyntaxError => e
      e.line_number ||= parse_context.line_number
      raise
    end

    private

    def new_body
      parse_context.new_block_body
    end

    def parse_body(tokenizer)
      @body.parse(tokenizer, parse_context) do |unknown_tag_name, unknown_tag_markup|
        if unknown_tag_name
          unknown_tag(unknown_tag_name, unknown_tag_markup, tokenizer)
          true
        else
          false
        end
      end
    end
  end
end

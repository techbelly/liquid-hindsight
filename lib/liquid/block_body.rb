# frozen_string_literal: true

require 'English'

module Liquid
  class BlockBody
    LiquidTagToken      = /\A\s*(#{TagName})\s*(.*?)\z/o
    FullToken           = /\A#{TagStart}#{WhitespaceControl}?(\s*)(#{TagName})(\s*)(.*?)#{WhitespaceControl}?#{TagEnd}\z/om
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}#{WhitespaceControl}?\s*(\w+)\s*(.*)?#{WhitespaceControl}?#{TagEnd}\z/om
    ContentOfVariable   = /\A#{VariableStart}#{WhitespaceControl}?(.*?)#{WhitespaceControl}?#{VariableEnd}\z/om
    WhitespaceOrNothing = /\A\s*\z/
    TAGSTART            = "{%"
    VARSTART            = "{{"

    attr_reader :nodelist

    def initialize
      @nodelist = []
      @blank    = true
    end

    def parse(tokenizer, parse_context, &block)
      raise FrozenError, "can't modify frozen Liquid::BlockBody" if frozen?

      parse_context.line_number = tokenizer.line_number

      parse_for_document(tokenizer, parse_context, &block)
    end

    # @api private
    def self.raise_missing_tag_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t("errors.syntax.tag_termination", token: token, tag_end: TagEnd.inspect)
    end

    # @api private
    def self.raise_missing_variable_terminator(token, parse_context)
      raise SyntaxError, parse_context.locale.t("errors.syntax.variable_termination", token: token, tag_end: VariableEnd.inspect)
    end

    private def handle_invalid_tag_token(token, parse_context)
      if token.end_with?('%}')
        yield token, token
      else
        BlockBody.raise_missing_tag_terminator(token, parse_context)
      end
    end

    private def parse_for_document(tokenizer, parse_context, &block)
      while (token = tokenizer.shift)
        next if token.empty?
        case
        when token.start_with?(TAGSTART)
          whitespace_handler(token, parse_context)
          unless token =~ FullToken
            return handle_invalid_tag_token(token, parse_context, &block)
          end

        when token.start_with?(VARSTART)
          whitespace_handler(token, parse_context)
          @nodelist << create_variable(token, parse_context)
        else
          if parse_context.trim_whitespace
          end
          parse_context.trim_whitespace = false
          @nodelist << token
          @blank &&= token.match?(WhitespaceOrNothing)
        end
        parse_context.line_number = tokenizer.line_number
      end
    end

    def whitespace_handler(token, parse_context)
      if token[2] == WhitespaceControl
        previous_token = @nodelist.last
        if previous_token.is_a?(String)
          first_byte = previous_token.getbyte(0)
          previous_token.rstrip!
        end
      end
      parse_context.trim_whitespace = (token[-3] == WhitespaceControl)
    end

    private

    def create_variable(token, parse_context)
      BlockBody.raise_missing_variable_terminator(token, parse_context)
    end
  end
end

# frozen_string_literal: true

require "strscan"

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    TAG_END = /%\}/
    TAG_OR_VARIABLE_START = /\{[\{\%]/
    NEWLINE = /\n/

    OPEN_CURLEY = "{".ord
    CLOSE_CURLEY = "}".ord
    PERCENTAGE = "%".ord

    def initialize(
      source:,
      string_scanner:,
      line_numbers: false,
      line_number: nil,
      for_liquid_tag: false
    )
      @line_number = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @source = source.to_s.to_str
      @offset = 0
      @tokens = []

      if @source
        @ss = string_scanner
        @ss.string = @source
        tokenize
      end
    end

    def shift
      token = @tokens[@offset]

      return unless token

      @offset += 1

      token
    end

    private

    def tokenize
      @tokens << shift_normal until @ss.eos?

      @source = nil
      @ss = nil
    end

    def shift_normal
      token = next_token

      return unless token

      token
    end

    def next_token
      # possible states: :text, :tag, :variable
      byte_a = @ss.peek_byte

      if byte_a == OPEN_CURLEY
        @ss.scan_byte

        byte_b = @ss.peek_byte

        @ss.pos -= 1
      end

      next_text_token
    end

    def next_text_token
      start = @ss.pos

      unless @ss.skip_until(TAG_OR_VARIABLE_START)
        token = @ss.rest
        @ss.terminate
        return token
      end

    rescue ::ArgumentError => e
      if e.message == "invalid byte sequence in #{@ss.string.encoding}"
        raise SyntaxError, "Invalid byte sequence in #{@ss.string.encoding}"
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Parser
    def initialize(input, reject_bare_brackets: false)
      ss = input.is_a?(StringScanner) ? input : StringScanner.new(input)
      @tokens = Lexer.tokenize(ss)
      @p      = 0
      @reject_bare_brackets = reject_bare_brackets
    end

    def jump(point)
      @p = point
    end

    def consume(type = nil)
      token = @tokens[@p]
      @p += 1
      token[1]
    end

    def look(type, ahead = 0)
      tok = @tokens[@p + ahead]
      return false unless tok
      tok[0] == type
    end

    def expression
      token = @tokens[@p]
      raise SyntaxError, "#{token} is not a valid expression"
    end
  end
end

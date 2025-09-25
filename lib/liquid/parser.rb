# frozen_string_literal: true

module Liquid
  class Parser
    def initialize(input, reject_bare_brackets: false)
      ss = input.is_a?(StringScanner) ? input : StringScanner.new(input)
      @tokens = Lexer.tokenize(ss)
      @p      = 0
      @reject_bare_brackets = reject_bare_brackets
    end

    def expression
      token = @tokens[@p]
      raise SyntaxError, "#{token} is not a valid expression"
    end
  end
end

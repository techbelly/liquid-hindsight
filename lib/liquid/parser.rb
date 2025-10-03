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

    def consume?(type)
      token = @tokens[@p]
      return false unless token && token[0] == type
      @p += 1
      token[1]
    end

    def id?(str)
      token = @tokens[@p]
      return false unless token && token[0] == :id
      return false unless token[1] == str
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
      case token[0]
      when :id
        str = consume
        str << variable_lookups
      when :string, :number
        consume
      else
        raise SyntaxError, "#{token} is not a valid expression"
      end
    end

    def variable_lookups
      str = +""
      loop do
        if look(:open_square)
          str << consume
          str << expression
          str << consume(:close_square)
        elsif look(:dot)
          str << consume
          str << consume(:id)
        else
          break
        end
      end
      str
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class ParserUnitTest < Minitest::Test
  include Liquid

  def test_invalid_expression
    assert_raises(SyntaxError) do
      p = new_parser("==")
      p.expression
    end
  end

  private

  def new_parser(str)
    Parser.new(StringScanner.new(str))
  end
end

# frozen_string_literal: true

require 'test_helper'

class ParserUnitTest < Minitest::Test
  include Liquid

  def test_consume
    p = new_parser("wat: 7")
    assert_equal('wat', p.consume(:id))
    assert_equal(':', p.consume(:colon))
    assert_equal('7', p.consume(:number))
  end

  def test_jump
    p = new_parser("wat: 7")
    p.jump(2)
    assert_equal('7', p.consume(:number))
  end

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

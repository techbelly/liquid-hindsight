# frozen_string_literal: true

require 'test_helper'

class LexerUnitTest < Minitest::Test
  include Liquid

  def test_specials
    assert_equal(
      [[:pipe, '|'], [:dot, '.'], [:colon, ':'], [:end_of_string]],
      tokenize('| .:'),
    )

    assert_equal(
      [[:open_square, '['], [:comma, ','], [:close_square, ']'], [:end_of_string]],
      tokenize('[,]'),
    )
  end

  def test_fancy_identifiers
    assert_equal([[:id, 'hi'], [:id, 'five?'], [:end_of_string]], tokenize('hi five?'))

    assert_equal([[:number, '2'], [:id, 'foo'], [:end_of_string]], tokenize('2foo'))
  end

  private

  def tokenize(input)
    Lexer.tokenize(StringScanner.new(input))
  end
end

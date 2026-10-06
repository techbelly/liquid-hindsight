# frozen_string_literal: true

require 'test_helper'

class LexerUnitTest < Minitest::Test
  include Liquid

  def test_strings
    assert_equal(
      [[:string, %('this is a test""')], [:string, %("wat 'lol'")], [:end_of_string]],
      tokenize(%( 'this is a test""' "wat 'lol'")),
    )
  end

  def test_integer
    assert_equal(
      [[:id, 'hi'], [:number, '50'], [:end_of_string]],
      tokenize('hi 50'),
    )
  end

  def test_float
    assert_equal(
      [[:id, 'hi'], [:number, '5.0'], [:end_of_string]],
      tokenize('hi 5.0'),
    )
  end

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

  def test_contains_as_attribute_name
    assert_equal(
      [[:id, "a"], [:dot, "."], [:id, "contains"], [:dot, "."], [:id, "b"], [:end_of_string]],
      tokenize("a.contains.b"),
    )
  end

  private

  def tokenize(input)
    Lexer.tokenize(StringScanner.new(input))
  end
end

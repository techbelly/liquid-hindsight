# frozen_string_literal: true

require 'test_helper'

class ParsingQuirksTest < Minitest::Test
  include Liquid

  def test_raise_on_single_close_bracet
    assert_raises(SyntaxError) do
      Template.parse("text {{method} oh nos!")
    end
  end

  def test_raise_on_label_and_no_close_bracets
    assert_raises(SyntaxError) do
      Template.parse("TEST {{ ")
    end
  end

  def test_raise_on_label_and_no_close_bracets_percent
    assert_raises(SyntaxError) do
      Template.parse("TEST {% ")
    end
  end

  def test_meaningless_parens_error
    with_error_modes(:strict) do
      assert_raises(SyntaxError) do
        markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_unexpected_characters_syntax_error
    with_error_modes(:strict) do
      assert_raises(SyntaxError) do
        markup = "true && false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
      assert_raises(SyntaxError) do
        markup = "false || true"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_raise_on_invalid_tag_delimiter
    assert_raises(Liquid::SyntaxError) do
      Template.new.parse('{% end %}')
    end
  end
end

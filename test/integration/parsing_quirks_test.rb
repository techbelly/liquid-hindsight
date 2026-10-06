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

  def test_error_on_empty_filter
    assert(Template.parse("{{test}}"))

    with_error_modes(:lax) do
      assert(Template.parse("{{|test}}"))
    end

    with_error_modes(:strict) do
      assert_raises(SyntaxError) { Template.parse("{{|test}}") }
      assert_raises(SyntaxError) { Template.parse("{{test |a|b|}}") }
    end
  end

  def test_raise_on_invalid_tag_delimiter
    assert_raises(Liquid::SyntaxError) do
      Template.new.parse('{% end %}')
    end
  end
end # ParsingQuirksTest

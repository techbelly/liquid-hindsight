# frozen_string_literal: true

require 'test_helper'

class IfElseTagTest < Minitest::Test
  include Liquid

  def test_if_boolean
    assert_template_result(' YES ', '{% if var %} YES {% endif %}', { 'var' => true })
  end

  def test_comparison_of_strings_containing_and_or_or
    awful_markup = "a == 'and' and b == 'or' and c == 'foo and bar' and d == 'bar or baz' and e == 'foo' and foo and bar"
    assigns      = { 'a' => 'and', 'b' => 'or', 'c' => 'foo and bar', 'd' => 'bar or baz', 'e' => 'foo', 'foo' => true, 'bar' => true }
    assert_template_result(' YES ', "{% if #{awful_markup} %} YES {% endif %}", assigns)
  end

  def test_comparison_of_expressions_starting_with_and_or_or
    assigns = { 'order' => { 'items_count' => 0 }, 'android' => { 'name' => 'Roy' } }
    assert_template_result(
      "YES",
      "{% if android.name == 'Roy' %}YES{% endif %}",
      assigns,
    )
    assert_template_result(
      "YES",
      "{% if order.items_count == 0 %}YES{% endif %}",
      assigns,
    )
  end

  def test_syntax_error_no_variable
    assert_raises(SyntaxError) { assert_template_result('', '{% if jerry == 1 %}') }
  end

  def test_syntax_error_no_expression
    assert_raises(SyntaxError) { assert_template_result('', '{% if %}') }
  end

  def test_operators_are_whitelisted
    assert_raises(SyntaxError) do
      assert_template_result('', %({% if 1 or throw or or 1 %}yes{% endif %}))
    end
  end
end

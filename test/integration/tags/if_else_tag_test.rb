# frozen_string_literal: true

require 'test_helper'

class IfElseTagTest < Minitest::Test
  include Liquid

  def test_if
    assert_template_result('  ', ' {% if false %} this text should not go into the output {% endif %} ')
    assert_template_result(
      '  this text should go into the output  ',
      ' {% if true %} this text should go into the output {% endif %} ',
    )
    assert_template_result('  you rock ?', '{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?')
  end

  def test_if_boolean
    assert_template_result(' YES ', '{% if var %} YES {% endif %}', { 'var' => true })
  end

  def test_if_or
    assert_template_result(' YES ', '{% if a or b %} YES {% endif %}', { 'a' => true, 'b' => true })
    assert_template_result(' YES ', '{% if a or b %} YES {% endif %}', { 'a' => true, 'b' => false })
    assert_template_result(' YES ', '{% if a or b %} YES {% endif %}', { 'a' => false, 'b' => true })
    assert_template_result('',      '{% if a or b %} YES {% endif %}', { 'a' => false, 'b' => false })

    assert_template_result(' YES ', '{% if a or b or c %} YES {% endif %}', { 'a' => false, 'b' => false, 'c' => true })
    assert_template_result('',      '{% if a or b or c %} YES {% endif %}', { 'a' => false, 'b' => false, 'c' => false })
  end

  def test_if_or_with_operators
    assert_template_result(' YES ', '{% if a == true or b == true %} YES {% endif %}', { 'a' => true, 'b' => true })
    assert_template_result(' YES ', '{% if a == true or b == false %} YES {% endif %}', { 'a' => true, 'b' => true })
    assert_template_result('', '{% if a == false or b == false %} YES {% endif %}', { 'a' => true, 'b' => true })
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

  def test_if_and
    assert_template_result(' YES ', '{% if true and true %} YES {% endif %}')
    assert_template_result('', '{% if false and true %} YES {% endif %}')
    assert_template_result('', '{% if true and false %} YES {% endif %}')
  end

  def test_comparisons_on_null
    assert_template_result('', '{% if null < 10 %} NO {% endif %}')
    assert_template_result('', '{% if null <= 10 %} NO {% endif %}')
    assert_template_result('', '{% if null >= 10 %} NO {% endif %}')
    assert_template_result('', '{% if null > 10 %} NO {% endif %}')

    assert_template_result('', '{% if 10 < null %} NO {% endif %}')
    assert_template_result('', '{% if 10 <= null %} NO {% endif %}')
    assert_template_result('', '{% if 10 >= null %} NO {% endif %}')
    assert_template_result('', '{% if 10 > null %} NO {% endif %}')
  end

  def test_syntax_error_no_variable
    assert_raises(SyntaxError) { assert_template_result('', '{% if jerry == 1 %}') }
  end

  def test_syntax_error_no_expression
    assert_raises(SyntaxError) { assert_template_result('', '{% if %}') }
  end

  def test_operators_are_ignored_unless_isolated
    original_op = Condition.operators['contains']
    Condition.operators['contains'] = :[]

    assert_template_result(
      'yes',
      %({% if 'gnomeslab-and-or-liquid' contains 'gnomeslab-and-or-liquid' %}yes{% endif %}),
    )
  ensure
    Condition.operators['contains'] = original_op
  end

  def test_operators_are_whitelisted
    assert_raises(SyntaxError) do
      assert_template_result('', %({% if 1 or throw or or 1 %}yes{% endif %}))
    end
  end
end

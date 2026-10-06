# frozen_string_literal: true

require 'test_helper'

class IfElseTagTest < Minitest::Test
  include Liquid

  def test_if_boolean
    assert_template_result(' YES ', '{% if var %} YES {% endif %}', { 'var' => true })
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

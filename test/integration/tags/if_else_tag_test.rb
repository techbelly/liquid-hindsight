# frozen_string_literal: true

require 'test_helper'

class IfElseTagTest < Minitest::Test
  include Liquid

  def test_hash_miss_generates_false
    assert_template_result('', '{% if foo.bar %} NO {% endif %}', { 'foo' => {} })
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

  def test_operators_are_whitelisted
    assert_raises(SyntaxError) do
      assert_template_result('', %({% if 1 or throw or or 1 %}yes{% endif %}))
    end
  end
end

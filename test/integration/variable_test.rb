# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class VariableTest < Minitest::Test
  include Liquid

  def test_if_tag_calls_to_liquid_value
    assert_template_result('one', '{% if foo == 1 %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('one', '{% if foo == eqv %}one{% endif %}', { 'foo' => IntegerDrop.new(1), 'eqv' => IntegerDrop.new(1) })
    assert_template_result('one', '{% if 0 < foo %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('one', '{% if foo > 0 %}one{% endif %}', { 'foo' => IntegerDrop.new('1') })
    assert_template_result('one', '{% if b > a %}one{% endif %}', { 'b' => IntegerDrop.new(1), 'a' => IntegerDrop.new(0) })
    assert_template_result('true', '{% if foo == true %}true{% endif %}', { 'foo' => BooleanDrop.new(true) })
    assert_template_result('true', '{% if foo %}true{% endif %}', { 'foo' => BooleanDrop.new(true) })

    assert_template_result('', '{% if foo %}true{% endif %}', { 'foo' => BooleanDrop.new(false) })
    assert_template_result('', '{% if foo == true %}True{% endif %}', { 'foo' => BooleanDrop.new(false) })
    assert_template_result('', '{% if foo and true %}SHOULD NOT HAPPEN{% endif %}', { 'foo' => BooleanDrop.new(false) })

    assert_template_result('one', '{% if a contains x %}one{% endif %}', { 'a' => [1], 'x' => IntegerDrop.new(1) })
  end

  def test_simple_with_whitespaces
    assert_template_result("  worked  ", "  {{ test }}  ", { "test" => "worked" })
    assert_template_result("  worked wonderfully  ", "  {{ test }}  ", { "test" => "worked wonderfully" })
  end

  def test_ignore_unknown
    assert_template_result("", "{{ test }}")
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class VariableTest < Minitest::Test
  include Liquid

  def test_simple_variable
    assert_template_result('worked', "{{test}}", { 'test' => 'worked' })
    assert_template_result('worked wonderfully', "{{test}}", { 'test' => 'worked wonderfully' })
  end

  def test_variable_render_calls_to_liquid
    assert_template_result('foobar', '{{ foo }}', { 'foo' => ThingWithToLiquid.new })
  end

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

  def test_expression_with_whitespace_in_square_brackets
    assert_template_result('result', "{{ a[ 'b' ] }}", { 'a' => { 'b' => 'result' } })
    assert_template_result('result', "{{ a[ self[ 'b' ] ] }}", { 'b' => 'c', 'a' => { 'c' => 'result' } })
  end

  def test_ignore_unknown
    assert_template_result("", "{{ test }}")
  end

  def test_hash_scoping
    assert_template_result('worked', "{{ test.test }}", { 'test' => { 'test' => 'worked' } })
    assert_template_result('worked', "{{ test . test }}", { 'test' => { 'test' => 'worked' } })
  end

  def test_false_renders_as_false
    assert_template_result("false", "{{ foo }}", { 'foo' => false })
    assert_template_result("false", "{{ false }}")
  end

  def test_preset_assigns
    template                 = Template.parse(%({{ test }}))
    template.assigns['test'] = 'worked'
    assert_equal('worked', template.render!)
  end

  def test_reuse_parsed_template
    template                     = Template.parse(%({{ greeting }} {{ name }}))
    template.assigns['greeting'] = 'Goodbye'
    assert_equal('Hello Tobi', template.render!('greeting' => 'Hello', 'name' => 'Tobi'))
    assert_equal('Hello ', template.render!('greeting' => 'Hello', 'unknown' => 'Tobi'))
    assert_equal('Hello Brian', template.render!('greeting' => 'Hello', 'name' => 'Brian'))
    assert_equal('Goodbye Brian', template.render!('name' => 'Brian'))
    assert_equal({ 'greeting' => 'Goodbye' }, template.assigns)
  end

  def test_hash_with_default_proc
    template        = Template.parse(%(Hello {{ test }}))
    assigns         = Hash.new { |_h, k| raise "Unknown variable '#{k}'" }
    assigns['test'] = 'Tobi'
    assert_equal('Hello Tobi', template.render!(assigns))
    assigns.delete('test')
    e = assert_raises(RuntimeError) do
      template.render!(assigns)
    end
    assert_equal("Unknown variable 'test'", e.message)
  end

  def test_multiline_variable
    assert_template_result("worked", "{{\ntest\n}}", { "test" => "worked" })
  end

  def test_render_symbol
    assert_template_result('bar', '{{ foo }}', { 'foo' => :bar })
  end

  def test_nested_array
    assert_template_result('', '{{ foo }}', { 'foo' => [[nil]] })
  end

  def test_double_nested_variable_lookup
    assert_template_result(
      'bar',
      '{{ list[list[settings.zero]]["foo"] }}',
      {
        'list' => [1, { 'foo' => 'bar' }],
        'settings' => SettingsDrop.new("zero" => 0),
        'bar' => 'foo',
      },
    )
  end
end

# frozen_string_literal: true

require 'test_helper'

class CycleTagTest < Minitest::Test
  def test_unnamed_cycle_dependent_counter_when_used_with_literal_values
    template = <<~LIQUID
      {%- cycle "1", "2" -%}
      {%- cycle "1", "2" -%}
      {%- cycle "1", "2" -%}
    LIQUID

    assert_template_result("121", template)
  end

  def test_optional_trailing_comma
    template = <<~LIQUID
      {%- cycle "1", "2", -%}
      {%- cycle "1", "2", -%}
      {%- cycle "1", "2", -%}
      {%- cycle "1", -%}
    LIQUID

    assert_template_result("1211", template)
  end

  def test_cycle_tag_without_arguments
    error = assert_raises(Liquid::SyntaxError) do
      Template.parse("{% cycle %}")
    end

    assert_match(/Syntax Error in 'cycle' - Valid syntax: cycle \[name :\] var/, error.message)
  end

  def test_cycle_tag_with_error_mode
    # QuotedFragment is more permissive than what Parser#expression allows.
    template1 = "{% assign 5 = 'b' %}{% cycle .5, .4 %}"
    template2 = "{% cycle .5: 'a', 'b' %}"

    with_error_modes(:lax, :strict) do
      assert_template_result("b", template1)
      assert_template_result("a", template2)
    end

    with_error_modes(:strict2) do
      error1 = assert_raises(Liquid::SyntaxError) { Template.parse(template1) }
      error2 = assert_raises(Liquid::SyntaxError) { Template.parse(template2) }

      assert_match(/Liquid syntax error:/, error1.message)
      assert_match(/Liquid syntax error: \[:dot, "."\] is not a valid expression/, error2.message)
    end
  end

  def test_cycle_name_with_invalid_expression
    template = <<~LIQUID
      {% for i in (1..3) %}
        {% cycle foo=>bar: "a", "b" %}
      {% endfor %}
    LIQUID

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_cycle_variable_with_invalid_expression
    template = <<~LIQUID
      {% for i in (1..3) %}
        {% cycle foo=>bar, "a", "b" %}
      {% endfor %}
    LIQUID

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end
end

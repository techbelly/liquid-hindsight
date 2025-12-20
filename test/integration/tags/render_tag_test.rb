# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_does_not_inherit_parent_scope_variables
    assert_template_result(
      '',
      '{% assign outer_variable = "should not be visible" %}{% render "snippet" %}',
      partials: { 'snippet' => '{{ outer_variable }}' },
    )
  end

  def test_render_does_not_inherit_variable_with_same_name_as_snippet
    assert_template_result(
      '',
      "{% assign snippet = 'should not be visible' %}{% render 'snippet' %}",
      partials: { 'snippet' => '{{ snippet }}' },
    )
  end

  def test_render_does_not_mutate_parent_scope
    assert_template_result(
      '',
      "{% render 'snippet' %}{{ inner }}",
      partials: { 'snippet' => '{% assign inner = 1 %}' },
    )
  end

  def test_dynamically_choosen_templates_are_not_allowed
    assert_syntax_error("{% assign name = 'snippet' %}{% render name %}")
  end

  def test_render_with_invalid_expression
    template = '{% render "snippet" with foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_render_attribute_with_invalid_expression
    template = '{% render "snippet", key: foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end
end

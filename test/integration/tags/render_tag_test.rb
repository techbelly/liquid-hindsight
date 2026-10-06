# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

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

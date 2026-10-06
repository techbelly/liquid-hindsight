# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_render_does_not_mutate_parent_scope
    assert_template_result(
      '',
      "{% render 'snippet' %}{{ inner }}",
      partials: { 'snippet' => '{% assign inner = 1 %}' },
    )
  end

  def test_nested_render_tag
    assert_template_result(
      'one two',
      "{% render 'one' %}",
      partials: {
        'one' => "one {% render 'two' %}",
        'two' => 'two',
      },
    )
  end

  def test_recursively_rendered_template_does_not_produce_endless_loop
    env = Liquid::Environment.build(
      file_system: StubFileSystem.new('loop' => '{% render "loop" %}'),
    )

    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop" %}', environment: env).render!
    end
  end

  def test_sub_contexts_count_towards_the_same_recursion_limit
    env = Liquid::Environment.build(
      file_system: StubFileSystem.new('loop_render' => '{% render "loop_render" %}'),
    )

    assert_raises(Liquid::StackLevelError) do
      Template.parse('{% render "loop_render" %}', environment: env).render!
    end
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

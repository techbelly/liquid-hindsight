# frozen_string_literal: true

require 'test_helper'

class TestFileSystem
  PARTIALS = {
    "nested_template" => "{% include 'header' %} {% include 'body' %} {% include 'footer' %}",
    "body" => "body {% include 'body_detail' %}",
  }

  def read_template_file(template_path)
    PARTIALS[template_path] || template_path
  end
end

class OtherFileSystem
  def read_template_file(_template_path)
    'from OtherFileSystem'
  end
end

class CountingFileSystem
  attr_reader :count
  def read_template_file(_template_path)
    @count ||= 0
    @count  += 1
    'from CountingFileSystem'
  end
end

class CustomInclude < Liquid::Tag
  Syntax = /(#{Liquid::QuotedFragment}+)(\s+(?:with|for)\s+(#{Liquid::QuotedFragment}+))?/o

  def initialize(tag_name, markup, tokens)
    markup =~ Syntax
    @template_name = Regexp.last_match(1)
    super
  end

  def parse(tokens)
  end

  def render_to_output_buffer(_context, output)
    output << @template_name[1..-2]
    output
  end
end

class IncludeTagTest < Minitest::Test
  include Liquid

  def test_included_templates_assigns_variables
    assert_template_result(
      "bar",
      "{% include 'assignments' %}{{ foo }}",
      partials: { 'assignments' => "{% assign foo = 'bar' %}" },
    )
  end

  def test_nested_include_tag
    partials = { "body" => "body {% include 'body_detail' %}", "body_detail" => "body_detail" }
    assert_template_result("body body_detail", "{% include 'body' %}", partials: partials)

    partials = partials.merge({
      "nested_template" => "{% include 'header' %} {% include 'body' %} {% include 'footer' %}",
      "header" => "header",
      "footer" => "footer",
    })
    assert_template_result("header body body_detail footer", "{% include 'nested_template' %}", partials: partials)
  end

  def test_recursively_included_template_does_not_produce_endless_loop
    infinite_file_system = Class.new do
      def read_template_file(_template_path)
        "-{% include 'loop' %}"
      end
    end

    env = Liquid::Environment.build(file_system: infinite_file_system.new)

    assert_raises(Liquid::StackLevelError) do
      Template.parse("{% include 'loop' %}", environment: env).render!
    end
  end

  def test_custom_include_tag
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal(
        "custom_foo",
        Template.parse("{% include 'custom_foo' %}").render!,
      )
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_custom_include_tag_within_if_statement
    original_tag = Liquid::Template.tags['include']
    Liquid::Template.tags['include'] = CustomInclude
    begin
      assert_equal(
        "custom_foo_if_true",
        Template.parse("{% if true %}{% include 'custom_foo_if_true' %}{% endif %}").render!,
      )
    ensure
      Liquid::Template.tags['include'] = original_tag
    end
  end

  def test_render_raise_argument_error_when_template_is_undefined
    assert_template_result(
      "Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include undefined_variable %}",
      render_errors: true,
    )

    assert_template_result(
      "Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include nil %}",
      render_errors: true,
    )
  end

  def test_render_raise_argument_error_when_template_is_not_a_string
    assert_template_result(
      "Liquid error (line 1): Argument error in tag 'include' - Illegal template name",
      "{% include 123 %}",
      render_errors: true,
    )
  end

  def test_include_template_with_invalid_expression
    template = "{% include foo=>bar %}"

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_include_with_invalid_expression
    template = '{% include "snippet" with foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_include_attribute_with_invalid_expression
    template = '{% include "snippet", key: foo=>bar %}'

    with_error_modes(:lax, :strict) do
      refute_nil(Template.parse(template))
    end

    with_error_modes(:strict2) do
      error = assert_raises(Liquid::SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end

  def test_include_for_loop_true_with_for_keyword
    with_error_modes(:lax, :strict, :strict2) do
      template = Template.parse("{% include 'product' for products %}")
      include_node = template.root.nodelist.first

      assert(include_node.for_loop?, "Expected for_loop? to be true for 'for' keyword")
    end
  end

  def test_include_for_loop_false_with_with_keyword
    with_error_modes(:lax, :strict, :strict2) do
      template = Template.parse("{% include 'product' with product %}")
      include_node = template.root.nodelist.first

      refute(include_node.for_loop?, "Expected for_loop? to be false for 'with' keyword")
    end
  end

  def test_include_for_loop_false_without_keyword
    with_error_modes(:lax, :strict, :strict2) do
      template = Template.parse("{% include 'header' %}")
      include_node = template.root.nodelist.first

      refute(include_node.for_loop?, "Expected for_loop? to be false when no keyword")
    end
  end

  def test_include_for_loop_with_alias
    with_error_modes(:lax, :strict, :strict2) do
      template = Template.parse("{% include 'product' for products as item %}")
      include_node = template.root.nodelist.first

      assert(include_node.for_loop?, "Expected for_loop? to be true for 'for' with alias")
    end
  end

  def test_include_with_keyword_and_alias
    with_error_modes(:lax, :strict, :strict2) do
      template = Template.parse("{% include 'product' with products[0] as item %}")
      include_node = template.root.nodelist.first

      refute(include_node.for_loop?, "Expected for_loop? to be false for 'with' with alias")
    end
  end
end # IncludeTagTest

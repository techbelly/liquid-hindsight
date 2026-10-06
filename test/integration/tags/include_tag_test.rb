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
end # IncludeTagTest

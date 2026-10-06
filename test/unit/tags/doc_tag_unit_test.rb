# frozen_string_literal: true

require 'test_helper'

class DocTagUnitTest < Minitest::Test
  def test_doc_tag_does_not_support_extra_arguments
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc extra %}
        {% enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  def test_doc_tag_does_not_allow_nested_docs
    error = assert_raises(Liquid::SyntaxError) do
      template = <<~LIQUID.chomp
        {% doc %}
          {% doc %}
            {% doc %}
        {% enddoc %}
      LIQUID

      Liquid::Template.parse(template)
    end

    exp_error = "Liquid syntax error: Syntax Error in 'doc' - Nested doc tags are not allowed"
    act_error = error.message

    assert_equal(exp_error, act_error)
  end

  private

  def traversal(template)
  end

  def visit(template)
    traversal(template).visit.flatten.compact
  end
end

# frozen_string_literal: true

require 'test_helper'

class DocTagUnitTest < Minitest::Test
  def test_doc_tag_body_content
    doc_content = "  Documentation content\n  @param {string} foo - test\n"
    template_source = "{% doc %}#{doc_content}{% enddoc %}"

    doc_tag = nil
    ParseTreeVisitor
      .for(Template.parse(template_source).root)
      .add_callback_for(Liquid::Doc) do |tag|
        doc_tag = tag
      end
      .visit

    assert_equal(doc_content, doc_tag.nodelist.first.to_s)
  end

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

  def test_doc_tag_must_support_valid_tags
    assert_match_syntax_error("Liquid syntax error (line 1): 'doc' tag was never closed", '{% doc %} foo')
    assert_match_syntax_error("Liquid syntax error (line 1): Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}", '{% doc } foo {% enddoc %}')
    assert_match_syntax_error("Liquid syntax error (line 1): Syntax Error in 'doc' - Valid syntax: {% doc %}{% enddoc %}", '{% doc } foo %}{% enddoc %}')
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

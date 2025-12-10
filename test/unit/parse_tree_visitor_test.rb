# frozen_string_literal: true

require 'test_helper'

class ParseTreeVisitorTest < Minitest::Test
  include Liquid

  def test_variable
    assert_equal(
      ["test"],
      visit(%({{ test }})),
    )
  end

  def test_varible_with_filter
    assert_equal(
      ["test", "infilter"],
      visit(%({{ test | split: infilter }})),
    )
  end

  def test_dynamic_variable
    assert_equal(
      ["test", "inlookup"],
      visit(%({{ test[inlookup] }})),
    )
  end

  def test_echo
    assert_equal(
      ["test"],
      visit(%({% echo test %})),
    )
  end

  def test_elsif_body
    assert_equal(
      ["test"],
      visit(%({% if 1 == 1 %}{% elsif 2 == 2 %}{{ test }}{% endif %})),
    )
  end

  def test_else_body
    assert_equal(
      ["test"],
      visit(%({% if 1 == 1 %}{% else %}{{ test }}{% endif %})),
    )
  end

  def test_for_body
    assert_equal(
      ["test"],
      visit(%({% for x in (1..5) %}{{ test }}{% endfor %})),
    )
  end

  def test_assign
    assert_equal(
      ["test"],
      visit(%({% assign x = test %})),
    )
  end

  def test_capture
    assert_equal(
      ["test"],
      visit(%({% capture x %}{{ test }}{% endcapture %})),
    )
  end

  def test_include
    assert_equal(
      ["test"],
      visit(%({% include test %})),
    )
  end

  def test_include_with
    assert_equal(
      ["test"],
      visit(%({% include "hai" with test %})),
    )
  end

  def test_include_for
    assert_equal(
      ["test"],
      visit(%({% include "hai" for test %})),
    )
  end

  def test_render_with
    assert_equal(
      ["test"],
      visit(%({% render "hai" with test %})),
    )
  end

  def test_render_for
    assert_equal(
      ["test"],
      visit(%({% render "hai" for test %})),
    )
  end

  private

  def traversal(template)
    ParseTreeVisitor
      .for(Template.parse(template).root)
      .add_callback_for(VariableLookup) { |node| node.name }
  end

  def visit(template)
    traversal(template).visit.flatten.compact
  end
end

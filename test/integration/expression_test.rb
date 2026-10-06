# frozen_string_literal: true

require 'test_helper'
require 'lru_redux'

class ExpressionTest < Minitest::Test
  def test_quirky_negative_sign_expression_markup
    result = Expression.parse("-", nil)
    assert(result.is_a?(VariableLookup))
    assert_equal("-", result.name)

    # for this template, the expression markup is "-"
    assert_template_result(
      "",
      "{{ - 'theme.css' - }}",
      error_mode: :lax,
    )
  end

  def test_safe_parse_with_variable_lookup
    parse_context = Liquid::ParseContext.new
    parser = parse_context.new_parser('product.title')
    result = Liquid::Expression.safe_parse(parser)

    assert_instance_of(Liquid::VariableLookup, result)
    assert_equal('product', result.name)
    assert_equal(['title'], result.lookups)
  end

  def test_safe_parse_with_number
    parse_context = Liquid::ParseContext.new
    parser = parse_context.new_parser('42')
    result = Liquid::Expression.safe_parse(parser)

    assert_equal(42, result)
  end

  def test_safe_parse_raises_syntax_error_for_invalid_expression
    parse_context = Liquid::ParseContext.new
    parser = parse_context.new_parser('')

    error = assert_raises(Liquid::SyntaxError) do
      Liquid::Expression.safe_parse(parser)
    end

    assert_match(/is not a valid expression/, error.message)
  end

  private

  def assert_expression_result(expect, markup, **assigns)
    liquid = "{% if expect == #{markup} %}pass{% else %}got {{ #{markup} }}{% endif %}"
    assert_template_result("pass", liquid, { "expect" => expect, **assigns })
  end
end

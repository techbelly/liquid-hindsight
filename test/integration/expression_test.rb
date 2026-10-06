# frozen_string_literal: true

require 'test_helper'
require 'lru_redux'

class ExpressionTest < Minitest::Test
  def test_keyword_literals
    assert_template_result("true", "{{ true }}")
    assert_expression_result(true, "true")
  end

  def test_string
    assert_template_result("single quoted", "{{'single quoted'}}")
    assert_template_result("double quoted", '{{"double quoted"}}')
    assert_template_result("spaced", "{{ 'spaced' }}")
    assert_template_result("spaced2", "{{ 'spaced2' }}")
    assert_template_result("emoji🔥", "{{ 'emoji🔥' }}")
  end

  def test_int
    assert_template_result("456", "{{ 456 }}")
    assert_expression_result(123, "123")
    assert_expression_result(12, "012")
  end

  def test_range
    assert_template_result("3..4", "{{ ( 3 .. 4 ) }}")
    assert_expression_result(1..2, "(1..2)")

    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type 'false' in range expression",
      "{{ (false..true) }}",
    )
    assert_match_syntax_error(
      "Liquid syntax error (line 1): Invalid expression type '(1..2)' in range expression",
      "{{ ((1..2)..3) }}",
    )
  end

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

  def test_expression_cache
    skip("Liquid-C does not support Expression caching") if defined?(Liquid::C) && Liquid::C.enabled

    cache = {}
    template = <<~LIQUID
      {% assign x = 1 %}
      {{ x }}
      {% assign x = 2 %}
      {{ x }}
      {% assign y = 1 %}
      {{ y }}
    LIQUID

    Liquid::Template.parse(template, expression_cache: cache).render

    assert_equal(
      ["1", "2", "x", "y"],
      cache.to_a.map { _1[0] }.sort,
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

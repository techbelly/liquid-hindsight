# frozen_string_literal: true

require 'test_helper'

class ParseContextUnitTest < Minitest::Test
  include Liquid

  def test_safe_parse_expression_with_variable_lookup
    parser_strict = strict_parse_context.new_parser('product.title')
    result_strict = strict_parse_context.safe_parse_expression(parser_strict)

    parser_strict2 = strict2_parse_context.new_parser('product.title')
    result_strict2 = strict2_parse_context.safe_parse_expression(parser_strict2)

    assert_instance_of(VariableLookup, result_strict)
    assert_equal('product', result_strict.name)
    assert_equal(['title'], result_strict.lookups)

    assert_instance_of(VariableLookup, result_strict2)
    assert_equal('product', result_strict2.name)
    assert_equal(['title'], result_strict2.lookups)
  end

  def test_safe_parse_expression_raises_syntax_error_for_invalid_expression
    parser_strict = strict_parse_context.new_parser('')
    parser_strict2 = strict2_parse_context.new_parser('')

    error_strict = assert_raises(Liquid::SyntaxError) do
      strict_parse_context.safe_parse_expression(parser_strict)
    end
    assert_match(/is not a valid expression/, error_strict.message)

    error_strict2 = assert_raises(Liquid::SyntaxError) do
      strict2_parse_context.safe_parse_expression(parser_strict2)
    end

    assert_match(/is not a valid expression/, error_strict2.message)
  end

  private

  def strict_parse_context
    @strict_parse_context ||= ParseContext.new(
      environment: Environment.build(error_mode: :strict),
    )
  end

  def strict2_parse_context
    @strict2_parse_context ||= ParseContext.new(
      environment: Environment.build(error_mode: :strict2),
    )
  end
end

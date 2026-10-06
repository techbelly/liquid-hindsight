# frozen_string_literal: true

require 'test_helper'

class ConditionUnitTest < Minitest::Test
  include Liquid

  def setup
    @context = Liquid::Context.new
  end

  def test_basic_condition
    assert_equal(false, Condition.new(1, '==', 2).evaluate(Context.new))
    assert_equal(true,  Condition.new(1, '==', 1).evaluate(Context.new))
  end

  def test_default_operators_evalute_true
    assert_evaluates_true(1, '==', 1)
    assert_evaluates_true(1, '!=', 2)
    assert_evaluates_true(1, '<>', 2)
    assert_evaluates_true(1, '<', 2)
    assert_evaluates_true(2, '>', 1)
    assert_evaluates_true(1, '>=', 1)
    assert_evaluates_true(2, '>=', 1)
    assert_evaluates_true(1, '<=', 2)
    assert_evaluates_true(1, '<=', 1)
    # negative numbers
    assert_evaluates_true(1, '>', -1)
    assert_evaluates_true(-1, '<', 1)
    assert_evaluates_true(1.0, '>', -1.0)
    assert_evaluates_true(-1.0, '<', 1.0)
  end

  def test_default_operators_evalute_false
    assert_evaluates_false(1, '==', 2)
    assert_evaluates_false(1, '!=', 1)
    assert_evaluates_false(1, '<>', 1)
    assert_evaluates_false(1, '<', 0)
    assert_evaluates_false(2, '>', 4)
    assert_evaluates_false(1, '>=', 3)
    assert_evaluates_false(2, '>=', 4)
    assert_evaluates_false(1, '<=', 0)
    assert_evaluates_false(1, '<=', 0)
  end

  def test_contains_works_on_strings
    assert_evaluates_true('bob', 'contains', 'o')
    assert_evaluates_true('bob', 'contains', 'b')
    assert_evaluates_true('bob', 'contains', 'bo')
    assert_evaluates_true('bob', 'contains', 'ob')
    assert_evaluates_true('bob', 'contains', 'bob')

    assert_evaluates_false('bob', 'contains', 'bob2')
    assert_evaluates_false('bob', 'contains', 'a')
    assert_evaluates_false('bob', 'contains', '---')
  end

  def test_contains_binary_encoding_compatibility_with_utf8
    assert_evaluates_true('🙈'.b, 'contains', '🙈')
    assert_evaluates_true('🙈', 'contains', '🙈'.b)
  end

  def test_invalid_comparation_operator
    assert_evaluates_argument_error(1, '~~', 0)
  end

  def test_comparation_of_int_and_str
    assert_evaluates_argument_error('1', '>', 0)
    assert_evaluates_argument_error('1', '<', 0)
    assert_evaluates_argument_error('1', '>=', 0)
    assert_evaluates_argument_error('1', '<=', 0)
  end

  def test_hash_compare_backwards_compatibility
    assert_nil(Condition.new({}, '>', 2).evaluate(Context.new))
    assert_nil(Condition.new(2, '>', {}).evaluate(Context.new))
    assert_equal(false, Condition.new({}, '==', 2).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 1 }, '==', 'a' => 1).evaluate(Context.new))
    assert_equal(true, Condition.new({ 'a' => 2 }, 'contains', 'a').evaluate(Context.new))
  end

  def test_contains_works_on_arrays
    @context          = Liquid::Context.new
    @context['array'] = [1, 2, 3, 4, 5]
    array_expr        = VariableLookup.new("array")

    assert_evaluates_false(array_expr, 'contains', 0)
    assert_evaluates_true(array_expr, 'contains', 1)
    assert_evaluates_true(array_expr, 'contains', 2)
    assert_evaluates_true(array_expr, 'contains', 3)
    assert_evaluates_true(array_expr, 'contains', 4)
    assert_evaluates_true(array_expr, 'contains', 5)
    assert_evaluates_false(array_expr, 'contains', 6)
    assert_evaluates_false(array_expr, 'contains', "1")
  end

  def test_contains_returns_false_for_nil_operands
    @context = Liquid::Context.new
    assert_evaluates_false(VariableLookup.new('not_assigned'), 'contains', '0')
    assert_evaluates_false(0, 'contains', VariableLookup.new('not_assigned'))
  end

  def test_contains_return_false_on_wrong_data_type
    assert_evaluates_false(1, 'contains', 0)
  end

  def test_contains_with_string_left_operand_coerces_right_operand_to_string
    assert_evaluates_true(' 1 ', 'contains', 1)
    assert_evaluates_false(' 1 ', 'contains', 2)
  end

  def test_or_condition
    condition = Condition.new(1, '==', 2)
    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))

    condition.or(Condition.new(1, '==', 1))

    assert_equal(true, condition.evaluate(Context.new))
  end

  def test_and_condition
    condition = Condition.new(1, '==', 1)

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 2))

    assert_equal(true, condition.evaluate(Context.new))

    condition.and(Condition.new(2, '==', 1))

    assert_equal(false, condition.evaluate(Context.new))
  end

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = proc { |_cond, left, right| left =~ /^#{right}/ }

    assert_evaluates_true('bob', 'starts_with', 'b')
    assert_evaluates_false('bob', 'starts_with', 'o')
  ensure
    Condition.operators.delete('starts_with')
  end

  def test_left_or_right_may_contain_operators
    @context        = Liquid::Context.new
    @context['one'] = @context['another'] = "gnomeslab-and-or-liquid"

    assert_evaluates_true(VariableLookup.new("one"), '==', VariableLookup.new("another"))
  end

  def test_default_context_is_deprecated
    if Gem::Version.new(Liquid::VERSION) >= Gem::Version.new('6.0.0')
    end

    _out, err = capture_io do
      assert_equal(true, Condition.new(1, '==', 1).evaluate)
    end

    expected = "DEPRECATION WARNING: Condition#evaluate without a context argument is deprecated " \
      "and will be removed from Liquid 6.0.0."
    assert_includes(err.lines.map(&:strip), expected)
  end

  # Tests for blank? comparison without ActiveSupport
  #
  # Ruby's standard library does not include blank? on String, Array, Hash, etc.
  # ActiveSupport adds blank? but Liquid must work without it. These tests verify
  # that Liquid implements blank? semantics internally for use in templates like:
  #   {% if x == blank %}...{% endif %}
  #
  # The blank? semantics match ActiveSupport's behavior:
  # - nil and false are blank
  # - Strings are blank if empty or contain only whitespace
  # - Arrays and Hashes are blank if empty
  # - true and numbers are never blank

  # Tests for empty? comparison without ActiveSupport
  #
  # empty? is distinct from blank? - it only checks if a collection has zero elements.
  # For strings, empty? checks length == 0, NOT whitespace content.
  # Ruby's standard library has empty? on String, Array, and Hash, but Liquid
  # provides a fallback implementation for consistency.

  def test_empty_with_empty_string
    # An empty string ("") has length 0, so it's empty.
    # Different from blank - empty is a stricter check.
    @context['empty_string'] = ''
    empty_literal = Condition.class_variable_get(:@@method_literals)['empty']

    assert_evaluates_true(VariableLookup.new('empty_string'), '==', empty_literal)
  end

  private

  def assert_evaluates_true(left, op, right)
    assert(
      Condition.new(left, op, right).evaluate(@context),
      "Evaluated false: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_false(left, op, right)
    assert(
      !Condition.new(left, op, right).evaluate(@context),
      "Evaluated true: #{left.inspect} #{op} #{right.inspect}",
    )
  end

  def assert_evaluates_argument_error(left, op, right)
    assert_raises(Liquid::ArgumentError) do
      Condition.new(left, op, right).evaluate(@context)
    end
  end
end # ConditionTest

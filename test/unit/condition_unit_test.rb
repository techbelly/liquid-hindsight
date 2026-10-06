# frozen_string_literal: true

require 'test_helper'

class ConditionUnitTest < Minitest::Test
  include Liquid

  def setup
    @context = Liquid::Context.new
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

  def test_should_allow_custom_proc_operator
    Condition.operators['starts_with'] = proc { |_cond, left, right| left =~ /^#{right}/ }

    assert_evaluates_true('bob', 'starts_with', 'b')
    assert_evaluates_false('bob', 'starts_with', 'o')
  ensure
    Condition.operators.delete('starts_with')
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

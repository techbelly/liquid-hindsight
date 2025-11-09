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
end

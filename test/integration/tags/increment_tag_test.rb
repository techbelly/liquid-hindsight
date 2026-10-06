# frozen_string_literal: true

require 'test_helper'

class IncrementTagTest < Minitest::Test
  include Liquid

  def test_increment_strict2_rejects_invalid_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment foo bar %}', error_mode: :strict2)
    end
  end

  def test_increment_strict2_rejects_variable_starting_with_number
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment 11aa %}', error_mode: :strict2)
    end
  end

  def test_decrement_strict2_rejects_variable_starting_with_number
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% decrement 11aa %}', error_mode: :strict2)
    end
  end

  def test_increment_strict2_rejects_empty_variable_name
    assert_raises(Liquid::SyntaxError) do
      Template.parse('{% increment %}', error_mode: :strict2)
    end
  end
end

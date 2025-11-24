# frozen_string_literal: true

require 'test_helper'

class AssignTest < Minitest::Test
  include Liquid

  def test_assign_syntax_error
    assert_match_syntax_error(/assign/, '{% assign foo not values %}.')
  end

  def test_assign_rejects_parentheses_in_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% assign (a(b(c) = 1234 %}", error_mode: :strict2)
    end
  end

  def test_assign_rejects_brackets_in_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% assign [x.y] = 'hello' %}", error_mode: :strict2)
    end
  end

  def test_assign_rejects_numeric_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% assign 1abc = 'hello' %}", error_mode: :strict2)
    end
  end

  private

  class ObjectWrapperDrop < Liquid::Drop
    def initialize(obj)
      @obj = obj
    end

    def value
      @obj
    end
  end

  def assign_score_of(obj)
    context = Liquid::Context.new('drop' => ObjectWrapperDrop.new(obj))
    Liquid::Template.parse('{% assign obj = drop.value %}').render!(context)
    context.resource_limits.assign_score
  end
end

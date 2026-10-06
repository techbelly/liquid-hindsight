# frozen_string_literal: true

require 'test_helper'

class AssignTest < Minitest::Test
  include Liquid

  def test_assign_syntax_error
    assert_match_syntax_error(/assign/, '{% assign foo not values %}.')
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

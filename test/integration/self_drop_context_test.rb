# frozen_string_literal: true

require 'test_helper'

class SelfDropContextTest < Minitest::Test
  include Liquid

  def test_self_drop_repeated_lookups_compare_equal_for_same_context
    context = Context.new
    drop = context.find_variable("self")
    cached_drop = context.find_variable("self")

    assert_same(drop, cached_drop)
    assert_equal(drop.object_id, cached_drop.object_id)
    assert_equal(drop, cached_drop)
  end
end

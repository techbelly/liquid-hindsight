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

  def test_assigned_self_drop_compares_equal_to_itself
    assert_template_result('T', '{% assign s = self %}{% if s == s %}T{% else %}F{% endif %}')
  end

  def test_distinct_self_assignments_compare_equal_for_same_context
    assert_template_result('T', '{% assign a = self %}{% assign b = self %}{% if a == b %}T{% else %}F{% endif %}')
  end

  def test_bare_self_compares_equal_to_bare_self
    assert_template_result('T', '{% if self == self %}T{% else %}F{% endif %}')
  end
end

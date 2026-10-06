# frozen_string_literal: true

require 'test_helper'

class RangeSliceUnitTest < Minitest::Test
  def test_non_integer_range_empty_windows_do_not_visit_a_sentinel_value
    limits = Liquid::ResourceLimits.new({})

    assert_equal([], Liquid::Utils.slice_collection_for_iteration('a'..'z', 2, 2, limits))
    assert_equal(0, limits.render_score)
    assert_equal(['a', 'b'], Liquid::Utils.slice_collection_for_iteration('a'..'z', 0, 2, limits))
    assert_equal(2, limits.render_score)
  end

  def test_standard_beginless_range_raises_for_empty_windows
    [[0, 0], [1, 0]].each do |from, to|
      assert_raises(TypeError) do
        Liquid::Utils.slice_collection_for_iteration(Range.new(nil, 3), from, to, Liquid::ResourceLimits.new({}))
      end
    end
  end

  def test_custom_range_to_a_is_sliced_with_a_budget
    range = Class.new(Range) do
      def to_a
        [1, 2, 3]
      end
    end.new(nil, 3)
    limits = Liquid::ResourceLimits.new(render_score_limit: 2)

    assert_raises(Liquid::MemoryError) do
      Liquid::Utils.slice_collection_for_iteration(range, 1, 3, limits, use_range_to_a: true)
    end
    assert_equal(3, limits.render_score)
  end
end

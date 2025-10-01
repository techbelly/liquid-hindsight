# frozen_string_literal: true

require 'test_helper'

class RangeSliceUnitTest < Minitest::Test
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

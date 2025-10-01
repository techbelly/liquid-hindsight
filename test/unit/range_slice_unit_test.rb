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
end

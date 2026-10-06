# frozen_string_literal: true

require 'test_helper'

class ResourceLimitsUnitTest < Minitest::Test
  def test_cumulative_scores_initialize_to_zero
    limits = Liquid::ResourceLimits.new({})
    assert_equal(0, limits.cumulative_render_score)
    assert_equal(0, limits.cumulative_assign_score)
  end
end

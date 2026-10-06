# frozen_string_literal: true

require 'test_helper'

class ResourceLimitsUnitTest < Minitest::Test
  def test_cumulative_scores_initialize_to_zero
    limits = Liquid::ResourceLimits.new({})
    assert_equal(0, limits.cumulative_render_score)
    assert_equal(0, limits.cumulative_assign_score)
  end

  def test_cumulative_limits_default_to_nil
    limits = Liquid::ResourceLimits.new({})
    assert_nil(limits.cumulative_render_score_limit)
    assert_nil(limits.cumulative_assign_score_limit)
  end

  def test_cumulative_limits_configurable_via_hash
    limits = Liquid::ResourceLimits.new(
      cumulative_render_score_limit: 500,
      cumulative_assign_score_limit: 300,
    )
    assert_equal(500, limits.cumulative_render_score_limit)
    assert_equal(300, limits.cumulative_assign_score_limit)
  end
end

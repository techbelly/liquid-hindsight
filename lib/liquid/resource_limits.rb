# frozen_string_literal: true

module Liquid
  class ResourceLimits
    attr_accessor :render_length_limit,
      :render_score_limit,
      :assign_score_limit,
      :cumulative_render_score_limit,
      :cumulative_assign_score_limit
    attr_reader :render_score,
      :assign_score,
      :cumulative_render_score,
      :cumulative_assign_score

    def initialize(limits)
      @render_length_limit           = limits[:render_length_limit]
      @render_score_limit            = limits[:render_score_limit]
      @assign_score_limit            = limits[:assign_score_limit]
      @cumulative_render_score_limit = limits[:cumulative_render_score_limit]
      @cumulative_assign_score_limit = limits[:cumulative_assign_score_limit]
      @cumulative_render_score = 0
      @cumulative_assign_score = 0
      reset
    end

    def increment_render_score(amount)
      @render_score += amount
      @cumulative_render_score += amount
      raise_limits_reached if @render_score_limit && @render_score > @render_score_limit
      raise_limits_reached if @cumulative_render_score_limit && @cumulative_render_score > @cumulative_render_score_limit
    end

    def raise_limits_reached
      @reached_limit = true
      raise MemoryError, "Memory limits exceeded"
    end

    def reached?
      @reached_limit
    end

    def reset
      @reached_limit = false
      @last_capture_length = nil
      @render_score = @assign_score = 0
      raise_limits_reached if @cumulative_render_score_limit && @cumulative_render_score > @cumulative_render_score_limit
      raise_limits_reached if @cumulative_assign_score_limit && @cumulative_assign_score > @cumulative_assign_score_limit
    end
  end
end

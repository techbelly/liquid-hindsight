# frozen_string_literal: true

require 'liquid/profiler/hooks'

module Liquid
  class Profiler
    include Enumerable

    attr_reader :total_time
    alias_method :total_render_time, :total_time

    def profile(template_name, &block)
      return yield if @current_children

      root_children = @root_children
      render_idx = root_children.length
      begin
        @current_children = root_children
        profile_node(template_name, &block)
      ensure
        @current_children = nil
        if (timing = root_children[render_idx])
          @total_time += timing.total_time
        end
      end
    end

    def each(&block)
      children.each(&block)
    end

    private
  end
end

# frozen_string_literal: true

require 'liquid/profiler/hooks'

module Liquid
  class Profiler
    include Enumerable

    def each(&block)
      children.each(&block)
    end

    private
  end
end

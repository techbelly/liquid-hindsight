# frozen_string_literal: true

module Liquid
  class Block < Tag
    MAX_DEPTH = 100

    def initialize(tag_name, markup, options)
      super
      @blank = true
    end

    private
  end
end

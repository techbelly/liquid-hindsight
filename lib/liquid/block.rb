# frozen_string_literal: true

module Liquid
  class Block < Tag
    def blank?
      @blank
    end

    private
  end
end

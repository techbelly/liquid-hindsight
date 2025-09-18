# frozen_string_literal: true

module Liquid
  class Doc < Block
    def blank?
      @body.empty?
    end

    private
  end
end

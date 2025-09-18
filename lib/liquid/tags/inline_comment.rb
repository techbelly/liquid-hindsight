# frozen_string_literal: true

module Liquid
  class InlineComment < Tag
    def blank?
      true
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Comment < Block
    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end

    private
  end
end

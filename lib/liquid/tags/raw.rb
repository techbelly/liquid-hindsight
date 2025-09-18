# frozen_string_literal: true

module Liquid
  class Raw < Block
    Syntax = /\A\s*\z/

    def blank?
      @body.empty?
    end

    protected
  end
end

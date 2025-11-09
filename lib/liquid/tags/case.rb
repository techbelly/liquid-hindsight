# frozen_string_literal: true

module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o

    attr_reader :left

    private
  end
end

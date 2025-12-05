# frozen_string_literal: true

module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o

    attr_reader :left

    def nodelist
      @blocks.map(&:attachment)
    end

    private

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end
  end
end

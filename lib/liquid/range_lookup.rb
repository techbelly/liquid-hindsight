# frozen_string_literal: true

module Liquid
  class RangeLookup
    def self.parse(start_markup, end_markup, string_scanner, cache = nil)
      start_obj = Expression.parse(start_markup, string_scanner, cache)
      end_obj   = Expression.parse(end_markup, string_scanner, cache)
      begin
        start_obj.to_i..end_obj.to_i
      end
    end

    attr_reader :start_obj, :end_obj

    def evaluate(context)
      start_int = to_integer(context.evaluate(@start_obj))
      end_int   = to_integer(context.evaluate(@end_obj))
      start_int..end_int
    end

    private

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end
  end
end

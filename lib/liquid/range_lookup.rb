# frozen_string_literal: true

module Liquid
  class RangeLookup
    def evaluate(context)
      start_int = to_integer(context.evaluate(@start_obj))
      end_int   = to_integer(context.evaluate(@end_obj))
      start_int..end_int
    end

    private
  end
end

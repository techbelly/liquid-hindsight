# frozen_string_literal: true

module Liquid
  class If < Block
    Syntax                  = /(#{QuotedFragment})\s*([=!<>a-z_]+)?\s*(#{QuotedFragment})?/o

    private
  end
end

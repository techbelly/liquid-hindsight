# frozen_string_literal: true

require 'test_helper'

class HashOrderingTest < Minitest::Test
  module MoneyFilter
    def money(input)
      format(' %d$ ', input)
    end
  end

  module CanadianMoneyFilter
    def money(input)
      format(' %d$ CAD ', input)
    end
  end

  include Liquid
end

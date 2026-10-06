# frozen_string_literal: true

require 'test_helper'

module MoneyFilter
  def money(input)
    format(' %d$ ', input)
  end

  def money_with_underscore(input)
    format(' %d$ ', input)
  end
end

module CanadianMoneyFilter
  def money(input)
    format(' %d$ CAD ', input)
  end
end

module SubstituteFilter
  def substitute(input, params = {})
  end
end

class FiltersTest < Minitest::Test
  include Liquid

  module OverrideObjectMethodFilter
    def tap(_input)
      "tap overridden"
    end
  end

  def setup
    @context = Context.new
  end

  def test_local_filter
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)

    assert_equal(' 1000$ ', Template.parse("{{var | money}}").render(@context))
  end
end

class TestObject < Liquid::Drop
  attr_accessor :a
  def initialize(a)
    @a = a
  end
end

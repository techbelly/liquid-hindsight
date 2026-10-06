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

  def test_underscore_in_filter_name
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    assert_equal(' 1000$ ', Template.parse("{{var | money_with_underscore}}").render(@context))
  end

  def test_second_filter_overwrites_first
    @context['var'] = 1000
    @context.add_filters(MoneyFilter)
    @context.add_filters(CanadianMoneyFilter)

    assert_equal(' 1000$ CAD ', Template.parse("{{var | money}}").render(@context))
  end

  def test_size
    assert_template_result("4", "{{var | size}}", { "var" => 'abcd' })
  end

  def test_join
    assert_template_result("1 2 3 4", "{{var | join}}", { "var" => [1, 2, 3, 4] })
  end

  def test_sort
    assert_template_result("1 2 3 4", "{{numbers | sort | join}}", { "numbers" => [2, 1, 4, 3] })
    assert_template_result(
      "alphabetic as expected",
      "{{words | sort | join}}",
      { "words" => ['expected', 'as', 'alphabetic'] },
    )
    assert_template_result("3", "{{value | sort}}", { "value" => 3 })
    assert_template_result('are flower', "{{arrays | sort | join}}", { 'arrays' => ['flower', 'are'] })
    assert_template_result(
      "Expected case sensitive",
      "{{case_sensitive | sort | join}}",
      { "case_sensitive" => ["sensitive", "Expected", "case"] },
    )
  end

  def test_strip_html
    assert_template_result("bla blub", "{{ var | strip_html }}", { "var" => "<b>bla blub</a>" })
  end
end

class TestObject < Liquid::Drop
  attr_accessor :a
  def initialize(a)
    @a = a
  end
end

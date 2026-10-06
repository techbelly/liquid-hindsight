# frozen_string_literal: true

require 'test_helper'

module SecurityFilter
  def add_one(input)
    "#{input} + 1"
  end
end

class SecurityTest < Minitest::Test
  include Liquid

  def setup
    @assigns = {}
  end

  def assert_no_new_symbols
    # Run once to trigger any first-time initialization which might create some symbols,
    # for example autoload or lazy method parsing might create symbols on first execution.
    yield

    # Ensure no new symbols for further runs, i.e. the code does not leak symbols
    current_symbols = Symbol.all_symbols
    yield
    assert_equal([], Symbol.all_symbols - current_symbols)
  end

  def test_more_than_max_depth_nested_blocks_raises_exception
    depth = Liquid::Block::MAX_DEPTH + 1
    code  = "{% if true %}" * depth + "rendered" + "{% endif %}" * depth
    assert_raises(Liquid::StackLevelError) do
      Template.parse(code).render!
    end
  end
end # SecurityTest

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

  def test_does_not_permanently_add_filters_to_symbol_table
    assert_no_new_symbols do
      Thread.new do
        test = %( {{ "some_string" | a_bad_filter }} )
        Template.parse(test).render!
        nil
      end.join

      GC.start
    end
  end

  def test_does_not_add_drop_methods_to_symbol_table
    assigns = { 'drop' => Drop.new }
    method_names = Array.new(3) { |index| "untrusted_drop_method_#{object_id}_#{index}" }

    method_names.each do |method_name|
      assert_equal("", Template.parse("{{ drop.#{method_name} }}").render!(assigns))
    end

    assert_equal([], Symbol.all_symbols.map(&:to_s) & method_names)
  end

  def assert_no_new_symbols
    yield

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
end

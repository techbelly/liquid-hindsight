# frozen_string_literal: true

require 'test_helper'

class RegistersUnitTest < Minitest::Test
  include Liquid

  def test_key
    static_register = Registers.new(a: 1, b: 2)
    static_register[:b] = 22
    static_register[:c] = 33

    assert_equal(true, static_register.key?(:a))
    assert_equal(true, static_register.key?(:b))
    assert_equal(true, static_register.key?(:c))
    assert_equal(false, static_register.key?(:d))
  end

  def test_static_register_can_be_frozen
    static_register = Registers.new(a: 1)

    static_register.static.freeze

    assert_raises(RuntimeError) do
      static_register.static[:a] = "foo"
    end

    assert_raises(RuntimeError) do
      static_register.static[:b] = "foo"
    end

    assert_raises(RuntimeError) do
      static_register.static.delete(:a)
    end

    assert_raises(RuntimeError) do
      static_register.static.delete(:c)
    end
  end
end

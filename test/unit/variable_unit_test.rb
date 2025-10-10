# frozen_string_literal: true

require 'test_helper'

class VariableUnitTest < Minitest::Test
  include Liquid

  def test_string_single_quoted
    var = create_variable(%( "hello" ))
    assert_equal('hello', var.name)
  end

  def test_string_double_quoted
    var = create_variable(%( 'hello' ))
    assert_equal('hello', var.name)
  end

  def test_integer
    var = create_variable(%( 1000 ))
    assert_equal(1000, var.name)
  end

  def test_float
    var = create_variable(%( 1000.01 ))
    assert_equal(1000.01, var.name)
  end

  def test_string_with_special_chars
    var = create_variable(%( 'hello! $!@.;"ddasd" ' ))
    assert_equal('hello! $!@.;"ddasd" ', var.name)
  end

  def test_variable_lookup_interface
    lookup = VariableLookup.new('a.b.c')
    assert_equal('a', lookup.name)
    assert_equal(['b', 'c'], lookup.lookups)
  end

  private

  def create_variable(markup, options = {})
    Variable.new(markup, ParseContext.new(options))
  end
end

# frozen_string_literal: true

require 'test_helper'

class VariableUnitTest < Minitest::Test
  include Liquid

  def test_variable
    var = create_variable('hello')
    assert_equal(VariableLookup.new('hello'), var.name)
  end

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

  def test_dashes
    assert_equal(VariableLookup.new('foo-bar'), create_variable('foo-bar').name)
    assert_equal(VariableLookup.new('foo-bar-2'), create_variable('foo-bar-2').name)

    with_error_modes(:strict) do
      assert_raises(Liquid::SyntaxError) { create_variable('foo - bar') }
      assert_raises(Liquid::SyntaxError) { create_variable('-foo') }
      assert_raises(Liquid::SyntaxError) { create_variable('2foo') }
    end
  end

  def test_string_with_special_chars
    var = create_variable(%( 'hello! $!@.;"ddasd" ' ))
    assert_equal('hello! $!@.;"ddasd" ', var.name)
  end

  def test_string_dot
    var = create_variable(%( test.test ))
    assert_equal(VariableLookup.new('test.test'), var.name)
  end

  def test_strict_filter_argument_parsing
    with_error_modes(:strict) do
      assert_raises(SyntaxError) do
        create_variable(%( number_of_comments | pluralize: 'comment': 'comments' ))
      end
    end
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

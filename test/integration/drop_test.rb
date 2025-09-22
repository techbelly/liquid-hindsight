# frozen_string_literal: true

require 'test_helper'

class ContextDrop < Liquid::Drop
  def scopes
    @context.scopes.size
  end

  def scopes_as_array
    (1..@context.scopes.size).to_a
  end

  def loop_pos
    @context['forloop.index']
  end

  def liquid_method_missing(method)
    @context[method]
  end
end

class ProductDrop < Liquid::Drop
  class TextDrop < Liquid::Drop
    def array
      ['text1', 'text2']
    end

    def text
      'text1'
    end
  end

  class CatchallDrop < Liquid::Drop
    def liquid_method_missing(method)
      "catchall_method: #{method}"
    end
  end

  def texts
    TextDrop.new
  end

  def catchall
    CatchallDrop.new
  end

  def context
    ContextDrop.new
  end

  protected

  def callmenot
    "protected"
  end
end

class EnumerableDrop < Liquid::Drop
  def liquid_method_missing(method)
    method
  end

  def size
    3
  end

  def first
    1
  end

  def count
    3
  end

  def min
    1
  end

  def max
    3
  end

  def each
    yield 1
    yield 2
    yield 3
  end
end

class RealEnumerableDrop < Liquid::Drop
  include Enumerable

  def liquid_method_missing(method)
    method
  end

  def each
    yield 1
    yield 2
    yield 3
  end
end

class DropsTest < Minitest::Test
  include Liquid

  def test_invokable_methods
    assert_equal(%w(to_liquid catchall context texts).to_set, ProductDrop.invokable_methods)
    assert_equal(%w(to_liquid scopes_as_array loop_pos scopes).to_set, ContextDrop.invokable_methods)
    assert_equal(%w(to_liquid size max min first count).to_set, EnumerableDrop.invokable_methods)
    assert_equal(%w(to_liquid max min sort count first).to_set, RealEnumerableDrop.invokable_methods)
  end
end

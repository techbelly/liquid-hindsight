# frozen_string_literal: true

require 'test_helper'

class HundredCentes
  def to_liquid
    100
  end
end

class CentsDrop < Liquid::Drop
  def amount
    HundredCentes.new
  end

  def non_zero?
    true
  end
end

class ContextSensitiveDrop < Liquid::Drop
  def test
    @context['test']
  end
end

class Category
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_liquid
    CategoryDrop.new(self)
  end
end

class ProductsDrop < Liquid::Drop
  def initialize(products)
    @products = products
  end

  def size
    @products.size
  end

  def to_liquid
    if @context["forloop"]
      @products.first(@context["forloop"].length)
    else
      @products
    end
  end
end

class CategoryDrop < Liquid::Drop
  attr_accessor :context

  def initialize(category)
    @category = category
  end
end

class CounterDrop < Liquid::Drop
  def count
    @count ||= 0
    @count  += 1
  end
end

class ArrayLike
  def fetch(index)
  end

  def [](index)
    @counts        ||= []
    @counts[index] ||= 0
    @counts[index]  += 1
  end

  def to_liquid
    self
  end
end

class ContextTest < Minitest::Test
  include Liquid

  def setup
    @context = Liquid::Context.new
  end

  def test_variables
    @context['string'] = 'string'
    assert_equal('string', @context['string'])

    @context['num'] = 5
    assert_equal(5, @context['num'])

    @context['time'] = Time.parse('2006-06-06 12:00:00')
    assert_equal(Time.parse('2006-06-06 12:00:00'), @context['time'])

    @context['date'] = Date.today
    assert_equal(Date.today, @context['date'])

    now = Time.now
    @context['datetime'] = now
    assert_equal(now, @context['datetime'])

    @context['bool'] = true
    assert_equal(true, @context['bool'])

    @context['bool'] = false
    assert_equal(false, @context['bool'])

    @context['nil'] = nil
    assert_nil(@context['nil'])
    assert_nil(@context['nil'])
  end

  def test_scoping
    @context.push
    @context.pop

    assert_raises(Liquid::ContextError) do
      @context.pop
    end

    assert_raises(Liquid::ContextError) do
      @context.push
      @context.pop
      @context.pop
    end
  end

  def test_add_item_in_outer_scope
    @context['test'] = 'test'
    @context.push
    assert_equal('test', @context['test'])
    @context.pop
    assert_equal('test', @context['test'])
  end

  def test_drop_with_variable_called_only_once
    @context['counter'] = CounterDrop.new

    assert_equal(1, @context['counter.count'])
    assert_equal(2, @context['counter.count'])
    assert_equal(3, @context['counter.count'])
  end

  def test_to_liquid_and_context_at_first_level
    @context['category'] = Category.new("foobar")
    assert_kind_of(CategoryDrop, @context['category'])
    assert_equal(@context, @context['category'].context)
  end

  def test_interrupt_avoids_object_allocations
    @context.interrupt?
    assert_no_object_allocations do
      @context.interrupt?
    end
  end

  def test_apply_global_filter
    global_filter_proc = ->(output) { "#{output} filtered" }

    context = Context.new
    context.global_filter = global_filter_proc

    assert_equal('hi filtered', context.apply_global_filter('hi'))
  end

  def test_apply_global_filter_when_no_global_filter_exist
    context = Context.new
    assert_equal('hi', context.apply_global_filter('hi'))
  end

  def test_disables_tag_specified
    context = Context.new
    context.with_disabled_tags(%w(foo bar)) do
      assert_equal(true, context.tag_disabled?("foo"))
      assert_equal(true, context.tag_disabled?("bar"))
      assert_equal(false, context.tag_disabled?("unknown"))
    end
  end

  def test_disables_nested_tags
    context = Context.new
    context.with_disabled_tags(["foo"]) do
      context.with_disabled_tags(["foo"]) do
        assert_equal(true, context.tag_disabled?("foo"))
        assert_equal(false, context.tag_disabled?("bar"))
      end
      context.with_disabled_tags(["bar"]) do
        assert_equal(true, context.tag_disabled?("foo"))
        assert_equal(true, context.tag_disabled?("bar"))
        context.with_disabled_tags(["foo"]) do
          assert_equal(true, context.tag_disabled?("foo"))
          assert_equal(true, context.tag_disabled?("bar"))
        end
      end
      assert_equal(true, context.tag_disabled?("foo"))
      assert_equal(false, context.tag_disabled?("bar"))
    end
  end

  def test_key_lookup_will_raise_for_missing_keys_when_strict_variables_is_enabled
    context = Context.new
    context.strict_variables = true
    assert_raises(Liquid::UndefinedVariable) do
      context['unknown']
    end
  end

  def test_context_always_uses_static_registers
    registers = {
      my_register: :my_value,
    }
    c = Context.new({}, {}, registers)
    assert_instance_of(Registers, c.registers)
    assert_equal(:my_value, c.registers[:my_register])

    r = Registers.new(registers)
    c = Context.new({}, {}, r)
    assert_instance_of(Registers, c.registers)
    assert_equal(:my_value, c.registers[:my_register])
  end

  private

  def assert_no_object_allocations
    require 'stackprof'

    profile = StackProf.run(mode: :object) do
      yield
    end
    assert_equal(0, profile[:samples])
  end
end

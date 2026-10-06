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
  attr_accessor :category, :context

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

  def test_add_item_in_inner_scope
    @context.push
    @context['test'] = 'test'
    assert_equal('test', @context['test'])
    @context.pop
    assert_nil(@context['test'])
  end

  def test_merge
    @context.merge("test" => "test")
    assert_equal('test', @context['test'])
    @context.merge("test" => "newvalue", "foo" => "bar")
    assert_equal('newvalue', @context['test'])
    assert_equal('bar', @context['foo'])
  end

  def test_cents
    @context.merge("cents" => HundredCentes.new)
    assert_equal(100, @context['cents'])
  end

  def test_nested_cents
    @context.merge("cents" => { 'amount' => HundredCentes.new })
    assert_equal(100, @context['cents.amount'])

    @context.merge("cents" => { 'cents' => { 'amount' => HundredCentes.new } })
    assert_equal(100, @context['cents.cents.amount'])
  end

  def test_cents_through_drop
    @context.merge("cents" => CentsDrop.new)
    assert_equal(100, @context['cents.amount'])
  end

  def test_nested_cents_through_drop
    @context.merge("vars" => { "cents" => CentsDrop.new })
    assert_equal(100, @context['vars.cents.amount'])
  end

  def test_drop_methods_with_question_marks
    @context.merge("cents" => CentsDrop.new)
    assert(@context['cents.non_zero?'])
  end

  def test_proc_as_variable
    @context['dynamic'] = proc { 'Hello' }

    assert_equal('Hello', @context['dynamic'])
  end

  def test_lambda_as_variable
    @context['dynamic'] = proc { 'Hello' }

    assert_equal('Hello', @context['dynamic'])
  end

  def test_nested_lambda_as_variable
    @context['dynamic'] = { "lambda" => proc { 'Hello' } }

    assert_equal('Hello', @context['dynamic.lambda'])
  end

  def test_lambda_is_called_once
    @global = 0

    @context['callcount'] = proc {
      @global += 1
      @global.to_s
    }

    assert_equal('1', @context['callcount'])
    assert_equal('1', @context['callcount'])
    assert_equal('1', @context['callcount'])
  end

  def test_nested_lambda_is_called_once
    @global = 0

    @context['callcount'] = {
      "lambda" => proc {
                    @global += 1
                    @global.to_s
                  },
    }

    assert_equal('1', @context['callcount.lambda'])
    assert_equal('1', @context['callcount.lambda'])
    assert_equal('1', @context['callcount.lambda'])
  end

  def test_access_to_context_from_proc
    @context.registers[:magic] = 345392

    @context['magic'] = proc { @context.registers[:magic] }

    assert_equal(345392, @context['magic'])
  end

  def test_to_liquid_and_context_at_first_level
    @context['category'] = Category.new("foobar")
    assert_kind_of(CategoryDrop, @context['category'])
    assert_equal(@context, @context['category'].context)
  end

  def test_interrupt_avoids_object_allocations
    @context.interrupt? # ruby 3.0.0 allocates on the first call
    assert_no_object_allocations do
      @context.interrupt?
    end
  end

  def test_context_initialization_with_a_proc_in_environment
    contx = Context.new([test: ->(c) { c['poutine'] }], test: :foo)

    assert(contx)
    assert_nil(contx['poutine'])
  end

  def test_apply_global_filter
    global_filter_proc = ->(output) { "#{output} filtered" }

    context = Context.new
    context.global_filter = global_filter_proc

    assert_equal('hi filtered', context.apply_global_filter('hi'))
  end

  def test_static_environments_are_read_with_lower_priority_than_environments
    context = Context.build(
      static_environments: { 'shadowed' => 'static', 'unshadowed' => 'static' },
      environments: { 'shadowed' => 'dynamic' },
    )

    assert_equal('dynamic', context['shadowed'])
    assert_equal('static', context['unshadowed'])
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

  def test_has_key_will_not_add_an_error_for_missing_keys
    with_error_modes(:strict) do
      context = Context.new
      context.key?('unknown')
      assert_empty(context.errors)
    end
  end

  def test_key_lookup_will_raise_for_missing_keys_when_strict_variables_is_enabled
    context = Context.new
    context.strict_variables = true
    assert_raises(Liquid::UndefinedVariable) do
      context['unknown']
    end
  end

  def test_has_key_will_not_raise_for_missing_keys_when_strict_variables_is_enabled
    context = Context.new
    context.strict_variables = true
    refute(context.key?('unknown'))
    assert_empty(context.errors)
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
end # ContextTest

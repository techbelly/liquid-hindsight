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

  def test_variables_not_existing
    assert_template_result("true", "{% if does_not_exist == nil %}true{% endif %}")
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

  def test_length_query
    assert_template_result(
      "true",
      "{% if numbers.size == 4 %}true{% endif %}",
      { "numbers" => [1, 2, 3, 4] },
    )

    assert_template_result(
      "true",
      "{% if numbers.size == 4 %}true{% endif %}",
      { "numbers" => { 1 => 1, 2 => 2, 3 => 3, 4 => 4 } },
    )

    assert_template_result(
      "true",
      "{% if numbers.size == 1000 %}true{% endif %}",
      { "numbers" => { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 'size' => 1000 } },
    )
  end

  def test_hyphenated_variable
    assert_template_result("godz", "{{ oh-my }}", { "oh-my" => 'godz' })
  end

  def test_add_filter
    filter = Module.new do
      def hi(output)
        output + ' hi!'
      end
    end

    context = Context.new
    context.add_filters(filter)
    assert_equal('hi? hi!', context.invoke(:hi, 'hi?'))

    context = Context.new
    assert_equal('hi?', context.invoke(:hi, 'hi?'))

    context.add_filters(filter)
    assert_equal('hi? hi!', context.invoke(:hi, 'hi?'))
  end

  def test_only_intended_filters_make_it_there
    filter = Module.new do
      def hi(output)
        output + ' hi!'
      end
    end

    context = Context.new
    assert_equal("Wookie", context.invoke("hi", "Wookie"))

    context.add_filters(filter)
    assert_equal("Wookie hi!", context.invoke("hi", "Wookie"))
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

  def test_keywords
    assert_template_result("pass", "{% if true == expect %}pass{% endif %}", { "expect" => true })
    assert_template_result("pass", "{% if false == expect %}pass{% endif %}", { "expect" => false })
  end

  def test_digits
    assert_template_result("pass", "{% if 100 == expect %}pass{% endif %}", { "expect" => 100 })
    assert_template_result("pass", "{% if 100.00 == expect %}pass{% endif %}", { "expect" => 100.00 })
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

  def test_context_from_within_drop
    @context.merge("test" => '123', "vars" => ContextSensitiveDrop.new)
    assert_equal('123', @context['vars.test'])
  end

  def test_nested_context_from_within_drop
    @context.merge("test" => '123', "vars" => { "local" => ContextSensitiveDrop.new })
    assert_equal('123', @context['vars.local.test'])
  end

  def test_cents_through_drop_nestedly
    @context.merge("cents" => { "cents" => CentsDrop.new })
    assert_equal(100, @context['cents.cents.amount'])

    @context.merge("cents" => { "cents" => { "cents" => CentsDrop.new } })
    assert_equal(100, @context['cents.cents.cents.amount'])
  end

  def test_drop_with_variable_called_only_once
    @context['counter'] = CounterDrop.new

    assert_equal(1, @context['counter.count'])
    assert_equal(2, @context['counter.count'])
    assert_equal(3, @context['counter.count'])
  end

  def test_drop_with_key_called_only_once
    @context['counter'] = CounterDrop.new

    assert_equal(1, @context['counter["count"]'])
    assert_equal(2, @context['counter["count"]'])
    assert_equal(3, @context['counter["count"]'])
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

  def test_array_containing_lambda_as_variable
    @context['dynamic'] = [1, 2, proc { 'Hello' }, 4, 5]

    assert_equal('Hello', @context['dynamic[2]'])
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

  def test_lambda_in_array_is_called_once
    @global = 0

    p = proc {
      @global += 1
      @global.to_s
    }
    @context['callcount'] = [1, 2, p, 4, 5]

    assert_equal('1', @context['callcount[2]'])
    assert_equal('1', @context['callcount[2]'])
    assert_equal('1', @context['callcount[2]'])
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

  def test_new_isolated_subcontext_does_not_inherit_variables
    super_context = Context.new
    super_context['my_variable'] = 'some value'
    subcontext = super_context.new_isolated_subcontext

    assert_nil(subcontext['my_variable'])
  end

  def test_new_isolated_subcontext_inherits_static_environment
    super_context = Context.build(static_environments: { 'my_environment_value' => 'my value' })
    subcontext    = super_context.new_isolated_subcontext

    assert_equal('my value', subcontext['my_environment_value'])
  end

  def test_new_isolated_subcontext_inherits_resource_limits
    resource_limits = ResourceLimits.new({})
    super_context   = Context.new({}, {}, {}, false, resource_limits)
    subcontext      = super_context.new_isolated_subcontext
    assert_equal(resource_limits, subcontext.resource_limits)
  end

  def test_new_isolated_subcontext_inherits_exception_renderer
    super_context = Context.new
    super_context.exception_renderer = ->(_e) { 'my exception message' }
    subcontext = super_context.new_isolated_subcontext
    assert_equal('my exception message', subcontext.handle_error(Liquid::Error.new))
  end

  def test_new_isolated_subcontext_does_not_inherit_non_static_registers
    registers = {
      my_register: :my_value,
    }
    super_context = Context.new({}, {}, Registers.new(registers))
    super_context.registers[:my_register] = :my_alt_value
    subcontext                            = super_context.new_isolated_subcontext
    assert_equal(:my_value, subcontext.registers[:my_register])
  end

  def test_new_isolated_subcontext_inherits_static_registers
    super_context = Context.build(registers: { my_register: :my_value })
    subcontext    = super_context.new_isolated_subcontext
    assert_equal(:my_value, subcontext.registers[:my_register])
  end

  def test_new_isolated_subcontext_registers_do_not_pollute_context
    super_context                      = Context.build(registers: { my_register: :my_value })
    subcontext                         = super_context.new_isolated_subcontext
    subcontext.registers[:my_register] = :my_alt_value
    assert_equal(:my_value, super_context.registers[:my_register])
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

  def test_new_isolated_context_inherits_parent_environment
    global_environment = Liquid::Environment.build(tags: {})
    context = Context.build(environment: global_environment)

    subcontext = context.new_isolated_subcontext
    assert_equal(global_environment, subcontext.environment)
  end

  def test_newly_built_context_inherits_parent_environment
    global_environment = Liquid::Environment.build(tags: {})
    context = Context.build(environment: global_environment)
    assert_equal(global_environment, context.environment)
    assert(context.environment.tags.each.to_a.empty?)
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

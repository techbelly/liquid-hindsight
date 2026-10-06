# frozen_string_literal: true

require 'test_helper'

class ThingWithValue < Liquid::Drop
  def value
    3
  end
end

class ForTagTest < Minitest::Test
  include Liquid

  def test_for_with_variable_range
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar) %} {{item}} {%endfor%}', { "foobar" => 3 })
  end

  def test_for_with_hash_value_range
    foobar = { "value" => 3 }
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar.value) %} {{item}} {%endfor%}', { "foobar" => foobar })
  end

  def test_limiting_with_invalid_limit
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: true offset: 1 %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_limiting_with_invalid_offset
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: 1 offset: true %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_blank_string_not_iterable
    assert_template_result('', "{% for char in characters %}I WILL NOT BE OUTPUT{% endfor %}", { 'characters' => '' })
  end

  def test_bad_variable_naming_in_for_loop
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse('{% for a/b in x %}{% endfor %}')
    end
  end

  class LoaderDrop < Liquid::Drop
    attr_accessor :each_called, :load_slice_called

    def initialize(data)
      @data = data
    end

    def each
      @each_called = true
    end

    def load_slice(from, to)
      @load_slice_called = true
      @data[(from..to - 1)]
    end
  end

  def test_for_cleans_up_registers
    context = Context.new(ErrorDrop.new)

    assert_raises(StandardError) do
      Liquid::Template.parse('{% for i in (1..2) %}{{ standard_error }}{% endfor %}').render!(context)
    end

    assert(context.registers[:for_stack].empty?)
  end

  def test_integer_range_is_not_materialized_and_charges_empty_iterations
    range = bounded_integer_range_with_tripwires
    template = Template.parse('{% for i in numbers %}{% endfor %}')
    template.resource_limits.render_score_limit = 3

    assert_raises(Liquid::MemoryError) { template.render!('numbers' => range) }

    assert(template.resource_limits.reached?)
    assert_equal(4, template.resource_limits.render_score)
  end

  def test_endless_range_remains_unsupported_with_a_limit
    template = Template.parse('{% for i in numbers limit:2 %}{{ i }}{% endfor %}')

    assert_raises(RangeError) { template.render!('numbers' => (1..)) }
  end

  def test_endless_range_subclass_with_custom_each_remains_unsupported
    range = Class.new(Range) do
      def each
      end
    end.new(1, nil)

    assert_raises(RangeError) do
      Template.parse('{% for i in numbers %}{{ i }}{% endfor %}').render!('numbers' => range)
    end
  end
end

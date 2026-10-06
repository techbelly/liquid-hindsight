# frozen_string_literal: true

require 'test_helper'

class ThingWithValue < Liquid::Drop
  def value
    3
  end
end

class ForTagTest < Minitest::Test
  include Liquid

  def test_for_with_range
    assert_template_result(' 1  2  3 ', '{%for item in (1..3) %} {{item}} {%endfor%}')

    assert_raises(Liquid::ArgumentError) do
      Template.parse('{% for i in (a..2) %}{% endfor %}').render!("a" => [1, 2])
    end

    assert_template_result(' 0  1  2  3 ', '{% for item in (a..3) %} {{item}} {% endfor %}', { "a" => "invalid integer" })
  end

  def test_for_with_variable_range
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar) %} {{item}} {%endfor%}', { "foobar" => 3 })
  end

  def test_for_with_hash_value_range
    foobar = { "value" => 3 }
    assert_template_result(' 1  2  3 ', '{%for item in (1..foobar.value) %} {{item}} {%endfor%}', { "foobar" => foobar })
  end

  def test_for_with_drop_value_range
    foobar = ThingWithValue.new
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

  def test_for_with_break_after_nested_loop
    source = <<~LIQUID.chomp
      {% for i in (1..2) -%}
        {% for j in (1..2) -%}
          {{ i }}-{{ j }},
        {%- endfor -%}
        {% break -%}
      {% endfor -%}
      after
    LIQUID
    assert_template_result("1-1,1-2,after", source)
  end

  def test_for_tag_string
    # ruby 1.8.7 "String".each => Enumerator with single "String" element.
    # ruby 1.9.3 no longer supports .each on String though we mimic
    # the functionality for backwards compatibility

    assert_template_result(
      'test string',
      '{%for val in string%}{{val}}{%endfor%}',
      { 'string' => "test string" },
    )

    assert_template_result(
      'test string',
      '{%for val in string limit:1%}{{val}}{%endfor%}',
      { 'string' => "test string" },
    )

    assert_template_result(
      'val-string-1-1-0-1-0-true-true-test string',
      '{%for val in string%}' \
      '{{forloop.name}}-' \
      '{{forloop.index}}-' \
      '{{forloop.length}}-' \
      '{{forloop.index0}}-' \
      '{{forloop.rindex}}-' \
      '{{forloop.rindex0}}-' \
      '{{forloop.first}}-' \
      '{{forloop.last}}-' \
      '{{val}}{%endfor%}',
      { 'string' => "test string" },
    )
  end

  def test_for_parentloop_references_parent_loop
    assert_template_result(
      '1.1 1.2 1.3 2.1 2.2 2.3 ',
      '{% for inner in outer %}{% for k in inner %}' \
      '{{ forloop.parentloop.index }}.{{ forloop.index }} ' \
      '{% endfor %}{% endfor %}',
      { 'outer' => [[1, 1, 1], [1, 1, 1]] },
    )
  end

  def test_inner_for_over_empty_input
    assert_template_result('oo', '{% for a in (1..2) %}o{% for b in empty %}{% endfor %}{% endfor %}')
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

  def test_iterate_with_load_slice_when_limit_applied
    loader   = LoaderDrop.new([1, 2, 3, 4, 5])
    assigns  = { 'items' => loader }
    expected = '1'
    template = '{% for item in items limit:1 %}{{item}}{% endfor %}'
    assert_template_result(expected, template, assigns)
    assert(!loader.each_called)
    assert(loader.load_slice_called)
  end

  def test_iterate_with_load_slice_when_limit_and_offset_applied
    loader   = LoaderDrop.new([1, 2, 3, 4, 5])
    assigns  = { 'items' => loader }
    expected = '34'
    template = '{% for item in items offset:2 limit:2 %}{{item}}{% endfor %}'
    assert_template_result(expected, template, assigns)
    assert(!loader.each_called)
    assert(loader.load_slice_called)
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

  def test_integer_range_uses_arithmetic_offsets_reversal_and_metadata
    range = bounded_integer_range_with_tripwires
    template = Template.parse(
      '{% for i in numbers reversed offset:997 limit:2 %}{{ forloop.length }}:{{ i }}{% endfor %}',
    )
    template.resource_limits.render_score_limit = 10

    assert_equal('2:9992:998', template.render!('numbers' => range))
  end

  def test_range_scores_cannot_be_bypassed_by_repeated_renders
    template = Template.parse('{% for i in (1..2) %}{% endfor %}')
    template.resource_limits.cumulative_render_score_limit = 3
    assert_equal('', template.render!)
    assert_raises(Liquid::MemoryError) { template.render! }
  end

  def test_range_break_charges_only_visited_items_and_preserves_full_metadata
    range = bounded_integer_range_with_tripwires
    template = Template.parse(
      '{% for i in numbers reversed %}{{ forloop.length }}:{{ i }}{% break %}{% endfor %}',
    )
    template.resource_limits.render_score_limit = 10

    assert_equal('1000:1000', template.render!('numbers' => range))
    assert_operator(template.resource_limits.render_score, :<=, 10)
  end

  def test_range_subclass_uses_its_custom_each
    range = Class.new(Range) do
      def each
        yield 10
        yield 20
      end
    end.new(nil, 3)

    assert_template_result('1020', '{% for i in numbers %}{{ i }}{% endfor %}', { 'numbers' => range })
  end

  def test_range_subclass_custom_to_a_is_honored_for_finite_and_open_bounds
    range_class = Class.new(Range) do
      def to_a
        [42]
      end
    end

    [range_class.new(1, 3), range_class.new(nil, 3), range_class.new(1, nil)].each do |range|
      assert_template_result('42', '{% for i in numbers %}{{ i }}{% endfor %}', { 'numbers' => range })
    end
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

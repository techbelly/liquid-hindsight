# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class TemplateContextDrop < Liquid::Drop
  def liquid_method_missing(method)
    method
  end

  def foo
    'fizzbuzz'
  end

  def baz
    @context.registers['lulz']
  end
end

class SomethingWithLength < Liquid::Drop
  def length
    nil
  end
end

class ErroneousDrop < Liquid::Drop
  def bad_method
    raise 'ruby error in drop'
  end
end

class DropWithUndefinedMethod < Liquid::Drop
  def foo
    'foo'
  end
end

class TemplateTest < Minitest::Test
  include Liquid

  def test_warnings_is_not_exponential_time
    str = "false"
    100.times do
      str = "{% if true %}true{% else %}#{str}{% endif %}"
    end

    t = Template.parse(str)
    assert_equal([], Timeout.timeout(1) { t.warnings })
  end

  def test_resource_limits_works_with_custom_length_method
    t = Template.parse("{% assign foo = bar %}")
    t.resource_limits.render_length_limit = 42
    assert_equal("", t.render!("bar" => SomethingWithLength.new))
  end

  def test_resource_limits_render_length
    t = Template.parse("0123456789")
    t.resource_limits.render_length_limit = 9
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    assert(t.resource_limits.reached?)

    t.resource_limits.render_length_limit = 10
    assert_equal("0123456789", t.render!)
  end

  def test_render_length_persists_between_blocks
    t = Template.parse("{% if true %}aaaa{% endif %}")
    t.resource_limits.render_length_limit = 3
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    t.resource_limits.render_length_limit = 4
    assert_equal("aaaa", t.render)

    t = Template.parse("{% if true %}aaaa{% endif %}{% if true %}bbb{% endif %}")
    t.resource_limits.render_length_limit = 6
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    t.resource_limits.render_length_limit = 7
    assert_equal("aaaabbb", t.render)

    t = Template.parse("{% if true %}a{% endif %}{% if true %}b{% endif %}{% if true %}a{% endif %}{% if true %}b{% endif %}{% if true %}a{% endif %}{% if true %}b{% endif %}")
    t.resource_limits.render_length_limit = 5
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    t.resource_limits.render_length_limit = 6
    assert_equal("ababab", t.render)
  end

  def test_render_length_uses_number_of_bytes_not_characters
    t = Template.parse("{% if true %}すごい{% endif %}")
    t.resource_limits.render_length_limit = 8
    assert_equal("Liquid error: Memory limits exceeded", t.render)
    t.resource_limits.render_length_limit = 9
    assert_equal("すごい", t.render)
  end

  def test_nil_value_does_not_raise
    t      = Template.parse("some{{x}}thing", error_mode: :strict)
    result = t.render!({ 'x' => nil }, strict_variables: true)

    assert_equal(0, t.errors.count)
    assert_equal('something', result)
  end

  def test_undefined_variables_raise
    t = Template.parse("{{x}} {{y}} {{z.a}} {{z.b}} {{z.c.d}}")

    assert_raises(UndefinedVariable) do
      t.render!({ 'x' => 33, 'z' => { 'a' => 32, 'c' => { 'e' => 31 } } }, strict_variables: true)
    end
  end

  def test_raises_error_with_invalid_utf8
    e = assert_raises(TemplateEncodingError) do
      Template.parse(<<~LIQUID)
        {% comment %}
          \xC0
        {% endcomment %}
      LIQUID
    end

    assert_equal('Liquid error: Invalid template encoding', e.message)
  end

  def test_allows_non_string_values_as_source
    assert_equal('', Template.parse(nil).render)
    assert_equal('1', Template.parse(1).render)
    assert_equal('true', Template.parse(true).render)
  end
end

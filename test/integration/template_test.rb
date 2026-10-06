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

  def test_render_bang_force_rethrow_errors_on_passed_context
    context = Context.new('drop' => ErroneousDrop.new)
    t = Template.new.parse('{{ drop.bad_method }}')

    e = assert_raises(RuntimeError) do
      t.render!(context)
    end
    assert_equal('ruby error in drop', e.message)
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

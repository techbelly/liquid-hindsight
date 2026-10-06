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
end

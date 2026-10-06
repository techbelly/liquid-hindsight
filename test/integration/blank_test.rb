# frozen_string_literal: true

require 'test_helper'

class FoobarTag < Liquid::Tag
  def render_to_output_buffer(_context, output)
    output << ' '
    output
  end
end

class BlankTest < Minitest::Test
  include Liquid
  N = 10

  def wrap_in_for(body)
    "{% for i in (1..#{N}) %}#{body}{% endfor %}"
  end

  def wrap_in_if(body)
    "{% if true %}#{body}{% endif %}"
  end

  def wrap(body)
    wrap_in_for(body) + wrap_in_if(body)
  end

  def test_if_else_are_blank
    assert_template_result("", "{% if true %} {% elsif false %} {% else %} {% endif %}")
  end
end

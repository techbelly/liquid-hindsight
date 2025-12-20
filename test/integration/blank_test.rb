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

  def test_loops_are_blank
    assert_template_result("", wrap_in_for(" "))
  end

  def test_if_else_are_blank
    assert_template_result("", "{% if true %} {% elsif false %} {% else %} {% endif %}")
  end

  def test_unless_is_blank
    assert_template_result("", wrap("{% unless true %} {% endunless %}"))
  end

  def test_comments_are_blank
    assert_template_result("", wrap(" {% comment %} whatever {% endcomment %} "))
  end

  def test_captures_are_blank
    assert_template_result("", wrap(" {% capture foo %} whatever {% endcapture %} "))
  end

  def test_assigns_are_blank
    assert_template_result("", wrap(' {% assign foo = "bar" %} '))
  end

  def test_whitespace_is_blank
    assert_template_result("", wrap(" "))
    assert_template_result("", wrap("\t"))
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class VariableTest < Minitest::Test
  include Liquid

  def test_ignore_unknown
    assert_template_result("", "{{ test }}")
  end

  def test_using_blank_as_variable_name
    assert_template_result("", "{% assign foo = blank %}{{ foo }}")
  end

  def test_using_empty_as_variable_name
    assert_template_result("", "{% assign foo = empty %}{{ foo }}")
  end

  def test_nested_array
    assert_template_result('', '{{ foo }}', { 'foo' => [[nil]] })
  end
end

# frozen_string_literal: true

require 'test_helper'

class UnlessElseTagTest < Minitest::Test
  include Liquid

  def test_unless
    assert_template_result('  ', ' {% unless true %} this text should not go into the output {% endunless %} ')
    assert_template_result(
      '  this text should go into the output  ',
      ' {% unless false %} this text should go into the output {% endunless %} ',
    )
    assert_template_result('  you rock ?', '{% unless true %} you suck {% endunless %} {% unless false %} you rock {% endunless %}?')
  end
end # UnlessElseTest

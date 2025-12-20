# frozen_string_literal: true

require 'test_helper'

class ContinueTagTest < Minitest::Test
  include Liquid

  def test_continue_with_no_block
    assigns  = {}
    markup   = '{% continue %}'
    expected = ''

    assert_template_result(expected, markup, assigns)
  end
end

# frozen_string_literal: true

require 'test_helper'

class BreakTagTest < Minitest::Test
  include Liquid

  def test_break_with_no_block
    assigns  = { 'i' => 1 }
    markup   = 'before{% break %}after'
    expected = 'before'

    assert_template_result(expected, markup, assigns)
  end
end

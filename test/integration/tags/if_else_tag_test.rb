# frozen_string_literal: true

require 'test_helper'

class IfElseTagTest < Minitest::Test
  include Liquid

  def test_syntax_error_no_expression
    assert_raises(SyntaxError) { assert_template_result('', '{% if %}') }
  end
end

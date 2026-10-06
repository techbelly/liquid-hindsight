# frozen_string_literal: true

require 'test_helper'

class CycleTagTest < Minitest::Test
  def test_cycle_tag_without_arguments
    error = assert_raises(Liquid::SyntaxError) do
      Template.parse("{% cycle %}")
    end

    assert_match(/Syntax Error in 'cycle' - Valid syntax: cycle \[name :\] var/, error.message)
  end
end

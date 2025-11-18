# frozen_string_literal: true

require 'test_helper'

class ParsingQuirksTest < Minitest::Test
  include Liquid

  def test_raise_on_single_close_bracet
    assert_raises(SyntaxError) do
      Template.parse("text {{method} oh nos!")
    end
  end
end

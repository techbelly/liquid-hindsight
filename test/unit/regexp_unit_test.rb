# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class RegexpUnitTest < Minitest::Test
  include Liquid

  def test_empty
    assert_equal([], ''.scan(QuotedFragment))
  end
end # RegexpTest

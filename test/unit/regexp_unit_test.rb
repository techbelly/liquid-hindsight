# frozen_string_literal: true

require 'test_helper'
require 'timeout'

class RegexpUnitTest < Minitest::Test
  include Liquid

  def test_empty
    assert_equal([], ''.scan(QuotedFragment))
  end

  def test_quote
    assert_equal(['"arg 1"'], '"arg 1"'.scan(QuotedFragment))
  end

  def test_words
    assert_equal(['arg1', 'arg2'], 'arg1 arg2'.scan(QuotedFragment))
  end
end # RegexpTest

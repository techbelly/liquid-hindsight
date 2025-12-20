# frozen_string_literal: true

require 'test_helper'

class TrimModeTest < Minitest::Test
  include Liquid

  def test_trim_blank
    assert_template_result('foobar', 'foo {{-}} bar')
  end
end

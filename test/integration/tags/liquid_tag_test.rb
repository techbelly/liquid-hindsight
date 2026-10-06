# frozen_string_literal: true

require 'test_helper'

class LiquidTagTest < Minitest::Test
  include Liquid

  def test_cannot_open_blocks_living_past_a_liquid_tag
    assert_match_syntax_error("syntax error (line 3): 'if' tag was never closed", <<~LIQUID)
      {%- liquid
        if true
      -%}
      {%- endif -%}
    LIQUID
  end
end

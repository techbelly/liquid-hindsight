# frozen_string_literal: true

require 'test_helper'

class InlineCommentTest < Minitest::Test
  include Liquid

  def test_inline_comment_returns_nothing
    assert_template_result('', '{%- # this is an inline comment -%}')
    assert_template_result('', '{%-# this is an inline comment -%}')
    assert_template_result('', '{% # this is an inline comment %}')
    assert_template_result('', '{%# this is an inline comment %}')
  end

  def test_inline_comments_require_the_pound_sign_on_every_new_line
    assert_match_syntax_error("Each line of comments must be prefixed by the '#' character", <<~LIQUID)
      {%-
        # some comment
        echo 'hello world'
      -%}
    LIQUID
  end
end

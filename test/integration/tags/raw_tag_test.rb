# frozen_string_literal: true

require 'test_helper'

class RawTagTest < Minitest::Test
  include Liquid

  def test_tag_in_raw
    assert_template_result(
      '{% comment %} test {% endcomment %}',
      '{% raw %}{% comment %} test {% endcomment %}{% endraw %}',
    )
  end

  def test_invalid_raw
    assert_match_syntax_error(/tag was never closed/, '{% raw %} foo')
    assert_match_syntax_error(/Valid syntax/, '{% raw } foo {% endraw %}')
    assert_match_syntax_error(/Valid syntax/, '{% raw } foo %}{% endraw %}')
  end
end

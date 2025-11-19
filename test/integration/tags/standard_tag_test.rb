# frozen_string_literal: true

require 'test_helper'

class StandardTagTest < Minitest::Test
  include Liquid

  def test_capture_detects_bad_syntax
    assert_raises(SyntaxError) do
      assert_template_result(
        'content foo content foo ',
        '{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
        { 'var' => 'content' },
      )
    end
  end

  def test_case_detects_bad_syntax
    assert_raises(SyntaxError) do
      assert_template_result('',  '{% case false %}{% when %}true{% endcase %}', {})
    end

    assert_raises(SyntaxError) do
      assert_template_result('',  '{% case false %}{% huh %}true{% endcase %}', {})
    end
  end
end

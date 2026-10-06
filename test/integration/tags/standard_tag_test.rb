# frozen_string_literal: true

require 'test_helper'

class StandardTagTest < Minitest::Test
  include Liquid

  def test_no_transform
    assert_template_result(
      'this text should come out of the template without change...',
      'this text should come out of the template without change...',
    )

    assert_template_result('blah', 'blah')
    assert_template_result('<blah>', '<blah>')
    assert_template_result('|,.:', '|,.:')
    assert_template_result('', '')

    text = %(this shouldnt see any transformation either but has multiple lines
              as you can clearly see here ...)
    assert_template_result(text, text)
  end

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
end # StandardTagTest

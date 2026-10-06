# frozen_string_literal: true

require 'test_helper'

class CaptureTest < Minitest::Test
  include Liquid

  def test_captures_block_content_in_variable
    assert_template_result("test string", "{% capture var %}test string{% endcapture %}{{var}}", {})
  end

  def test_capture_rejects_parentheses_in_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% capture (x[y %}hello{% endcapture %}", error_mode: :strict2)
    end
  end

  def test_capture_rejects_dot_in_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% capture a.b %}hello{% endcapture %}", error_mode: :strict2)
    end
  end

  def test_capture_rejects_numeric_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% capture 1abc %}hello{% endcapture %}", error_mode: :strict2)
    end
  end

  def test_capture_allows_invalid_names_in_lax
    t = Liquid::Template.parse("{% capture (x[y %}hello{% endcapture %}", error_mode: :lax)
    assert_equal("(x[y", t.root.nodelist.first.to)
  end
end

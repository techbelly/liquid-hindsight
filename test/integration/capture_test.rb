# frozen_string_literal: true

require 'test_helper'

class CaptureTest < Minitest::Test
  include Liquid

  def test_capture_rejects_parentheses_in_variable_name_in_strict2
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse("{% capture (x[y %}hello{% endcapture %}", error_mode: :strict2)
    end
  end
end

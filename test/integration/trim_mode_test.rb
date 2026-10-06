# frozen_string_literal: true

require 'test_helper'

class TrimModeTest < Minitest::Test
  include Liquid

  def test_tag_output_with_multiple_blank_lines
    text = <<-END_TEMPLATE
      <div>
        <p>

          {%- if true -%}
          yes
          {%- endif -%}

        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>yes</p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end
end # TrimModeTest

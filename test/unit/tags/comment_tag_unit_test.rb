# frozen_string_literal: true

require 'test_helper'

class CommentTagUnitTest < Minitest::Test
  def test_does_not_parse_nodes_inside_a_comment
    assert_template_result("", <<~LIQUID.chomp)
      {% comment %}
        {% if true %}
        {% if ... %}
        {%- for ? -%}
        {% while true %}
        {%
          unless if
        %}
        {% endcase %}
      {% endcomment %}
    LIQUID
  end
end

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

  def test_allows_unclosed_tags
    assert_template_result('', <<~LIQUID.chomp)
      {% comment %}
        {% if true %}
      {% endcomment %}
    LIQUID
  end

  def test_nested_comment_tag_with_extra_strings
    assert_template_result(
      '',
      <<~LIQUID.chomp,
        {% comment %}
          {% comment
            {% assign foo = 1 %}
          {% endcomment
          {% assign foo = 1 %}
        {% endcomment %}
      LIQUID
    )
  end

  def test_delimiter_can_have_extra_strings
    assert_template_result('', "{% comment %}123{% endcomment xyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\txyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\nxyz %}")
    assert_template_result('', "{% comment %}123{% endcomment\n   xyz  endcomment %}")
    assert_template_result('', "{%comment}{% assign a = 1 %}{%endcomment}{% endif %}")
  end

  def test_with_whitespace_control
    assert_template_result("Hello!", "      {%- comment -%}123{%- endcomment -%}Hello!")
    assert_template_result("Hello!", "{%- comment -%}123{%- endcomment -%}     Hello!")
    assert_template_result("Hello!", "      {%- comment -%}123{%- endcomment -%}     Hello!")

    assert_template_result("Hello!", <<~LIQUID.chomp)
      {%- comment %}Whitespace control!{% endcomment -%}
      Hello!
    LIQUID
  end
end

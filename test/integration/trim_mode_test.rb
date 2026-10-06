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

  # Make sure the trim isn't applied to standard tags
  def test_standard_tags
    whitespace = '          '
    text       = <<-END_TEMPLATE
      <div>
        <p>
          {% if true %}
          yes
          {% endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<~END_EXPECTED
            <div>
              <p>
      #{whitespace}
                yes
      #{whitespace}
              </p>
            </div>
    END_EXPECTED
    assert_template_result(expected, text)

    text = <<-END_TEMPLATE
      <div>
        <p>
          {% if false %}
          no
          {% endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<~END_EXPECTED
            <div>
              <p>
      #{whitespace}
              </p>
            </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end

  # Make sure the trim isn't too agressive
  def test_no_trim_tags
    text     = '<p>{%- if true -%}yes{%- endif -%}</p>'
    expected = '<p>yes</p>'
    assert_template_result(expected, text)

    text     = '<p>{%- if false -%}no{%- endif -%}</p>'
    expected = '<p></p>'
    assert_template_result(expected, text)
  end

  def test_single_line_outer_tag
    text     = '<p> {%- if true %} yes {% endif -%} </p>'
    expected = '<p> yes </p>'
    assert_template_result(expected, text)

    text     = '<p> {%- if false %} no {% endif -%} </p>'
    expected = '<p></p>'
    assert_template_result(expected, text)
  end

  def test_single_line_inner_tag
    text     = '<p> {% if true -%} yes {%- endif %} </p>'
    expected = '<p> yes </p>'
    assert_template_result(expected, text)

    text     = '<p> {% if false -%} no {%- endif %} </p>'
    expected = '<p>  </p>'
    assert_template_result(expected, text)
  end

  def test_single_line_post_tag
    text     = '<p> {% if true -%} yes {% endif -%} </p>'
    expected = '<p> yes </p>'
    assert_template_result(expected, text)

    text     = '<p> {% if false -%} no {% endif -%} </p>'
    expected = '<p> </p>'
    assert_template_result(expected, text)
  end

  def test_single_line_pre_tag
    text     = '<p> {%- if true %} yes {%- endif %} </p>'
    expected = '<p> yes </p>'
    assert_template_result(expected, text)

    text     = '<p> {%- if false %} no {%- endif %} </p>'
    expected = '<p> </p>'
    assert_template_result(expected, text)
  end

  def test_pre_trim_tags
    text = <<-END_TEMPLATE
      <div>
        <p>
          {%- if true %}
          yes
          {%- endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
          yes
        </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)

    text = <<-END_TEMPLATE
      <div>
        <p>
          {%- if false %}
          no
          {%- endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
        </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end

  def test_post_trim_tags
    text = <<-END_TEMPLATE
      <div>
        <p>
          {% if true -%}
          yes
          {% endif -%}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
          yes
          </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)

    text = <<-END_TEMPLATE
      <div>
        <p>
          {% if false -%}
          no
          {% endif -%}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
          </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end

  def test_pre_and_post_trim_tags
    text = <<-END_TEMPLATE
      <div>
        <p>
          {%- if true %}
          yes
          {% endif -%}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
          yes
          </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)

    text = <<-END_TEMPLATE
      <div>
        <p>
          {%- if false %}
          no
          {% endif -%}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p></p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end

  def test_post_and_pre_trim_tags
    text = <<-END_TEMPLATE
      <div>
        <p>
          {% if true -%}
          yes
          {%- endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p>
          yes
        </p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)

    whitespace = '          '
    text       = <<-END_TEMPLATE
      <div>
        <p>
          {% if false -%}
          no
          {%- endif %}
        </p>
      </div>
    END_TEMPLATE
    expected = <<~END_EXPECTED
            <div>
              <p>
      #{whitespace}
              </p>
            </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end

  def test_trim_tags
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

    text = <<-END_TEMPLATE
      <div>
        <p>
          {%- if false -%}
          no
          {%- endif -%}
        </p>
      </div>
    END_TEMPLATE
    expected = <<-END_EXPECTED
      <div>
        <p></p>
      </div>
    END_EXPECTED
    assert_template_result(expected, text)
  end
end # TrimModeTest

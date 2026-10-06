# frozen_string_literal: true

require 'test_helper'

class ErrorHandlingTest < Minitest::Test
  include Liquid

  def test_unrecognized_operator
    with_error_modes(:strict) do
      assert_raises(SyntaxError) do
        Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ')
      end
    end
  end

  def test_with_line_numbers_adds_numbers_to_parser_errors
    source = <<~LIQUID
      foobar

      {% "cat" | foobar %}

      bla
    LIQUID
    assert_match_syntax_error(/Liquid syntax error \(line 3\)/, source)
  end

  def test_with_line_numbers_adds_numbers_to_parser_errors_with_whitespace_trim
    source = <<~LIQUID
      foobar

      {%- "cat" | foobar -%}

      bla
    LIQUID

    assert_match_syntax_error(/Liquid syntax error \(line 3\)/, source)
  end

  def test_parsing_warn_with_line_numbers_adds_numbers_to_lexer_errors
    template = Liquid::Template.parse(
      '
        foobar

        {% if 1 =! 2 %}ok{% endif %}

        bla
            ',
      error_mode: :warn,
      line_numbers: true,
    )

    assert_equal(
      ['Liquid syntax error (line 4): Unexpected character = in "1 =! 2"'],
      template.warnings.map(&:message),
    )
  end

  def test_parsing_strict_with_line_numbers_adds_numbers_to_lexer_errors
    err = assert_raises(SyntaxError) do
      Liquid::Template.parse(
        '
          foobar

          {% if 1 =! 2 %}ok{% endif %}

          bla
                ',
        error_mode: :strict,
        line_numbers: true,
      )
    end

    assert_equal('Liquid syntax error (line 4): Unexpected character = in "1 =! 2"', err.message)
  end

  def test_syntax_errors_in_nested_blocks_have_correct_line_number
    source = <<~LIQUID
      foobar

      {% if 1 != 2 %}
        {% foo %}
      {% endif %}

      bla
    LIQUID

    assert_match_syntax_error("Liquid syntax error (line 4): Unknown tag 'foo'", source)
  end

  def test_strict_error_messages
    err = assert_raises(SyntaxError) do
      Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', error_mode: :strict)
    end
    assert_equal('Liquid syntax error: Unexpected character = in "1 =! 2"', err.message)

    err = assert_raises(SyntaxError) do
      Liquid::Template.parse('{{%%%}}', error_mode: :strict)
    end
    assert_equal('Liquid syntax error: Unexpected character % in "{{%%%}}"', err.message)
  end

  class TestFileSystem
    def read_template_file(_template_path)
      "{{ errors.argument_error }}"
    end
  end
end

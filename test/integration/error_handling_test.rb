# frozen_string_literal: true

require 'test_helper'

class ErrorHandlingTest < Minitest::Test
  include Liquid

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

  class TestFileSystem
    def read_template_file(_template_path)
      "{{ errors.argument_error }}"
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class ErrorHandlingTest < Minitest::Test
  include Liquid

  def test_templates_parsed_with_line_numbers_renders_them_in_errors
    template = <<-LIQUID
      Hello,

      {{ errors.standard_error }} will raise a standard error.

      Bla bla test.

      {{ errors.syntax_error }} will raise a syntax error.

      This is an argument error: {{ errors.argument_error }}

      Bla.
    LIQUID

    expected = <<-TEXT
      Hello,

      Liquid error (line 3): standard error will raise a standard error.

      Bla bla test.

      Liquid syntax error (line 7): syntax error will raise a syntax error.

      This is an argument error: Liquid error (line 9): argument error

      Bla.
    TEXT

    output = Liquid::Template.parse(template, line_numbers: true).render('errors' => ErrorDrop.new)
    assert_equal(expected, output)
  end

  def test_standard_error
    template = Liquid::Template.parse(' {{ errors.standard_error }} ')
    assert_equal(' Liquid error: standard error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(StandardError, template.errors.first.class)
  end

  def test_syntax
    template = Liquid::Template.parse(' {{ errors.syntax_error }} ')
    assert_equal(' Liquid syntax error: syntax error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(SyntaxError, template.errors.first.class)
  end

  def test_argument
    template = Liquid::Template.parse(' {{ errors.argument_error }} ')
    assert_equal(' Liquid error: argument error ', template.render('errors' => ErrorDrop.new))

    assert_equal(1, template.errors.size)
    assert_equal(ArgumentError, template.errors.first.class)
  end

  def test_missing_endtag_parse_time_error
    assert_match_syntax_error(/: 'for' tag was never closed\z/, ' {% for a in b %} ... ')
  end

  def test_unrecognized_operator
    with_error_modes(:strict) do
      assert_raises(SyntaxError) do
        Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ')
      end
    end
  end

  def test_lax_unrecognized_operator
    template = Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', error_mode: :lax)
    assert_equal(' Liquid error: Unknown operator =! ', template.render)
    assert_equal(1, template.errors.size)
    assert_equal(Liquid::ArgumentError, template.errors.first.class)
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

  def test_warning_line_numbers
    template = Liquid::Template.parse("{% if ~~~ %}\n{{%%%}}{% else %}\n{{ hello. }}{% endif %}", error_mode: :warn, line_numbers: true)
    assert_equal('Liquid syntax error (line 1): Unexpected character ~ in "~~~"', template.warnings[0].message)
    assert_equal('Liquid syntax error (line 2): Unexpected character % in "{{%%%}}"', template.warnings[1].message)
    assert_equal('Liquid syntax error (line 3): Expected id but found end_of_string in "{{ hello. }}"', template.warnings[2].message)
    assert_equal(3, template.warnings.size)
    assert_equal([1, 2, 3], template.warnings.map(&:line_number))
  end

  # Liquid should not catch Exceptions that are not subclasses of StandardError, like Interrupt and NoMemoryError
  def test_exceptions_propagate
    assert_raises(Exception) do
      template = Liquid::Template.parse('{{ errors.exception }}')
      template.render('errors' => ErrorDrop.new)
    end
  end

  def test_default_exception_renderer_with_internal_error
    template = Liquid::Template.parse('This is a runtime error: {{ errors.runtime_error }}', line_numbers: true)

    output = template.render('errors' => ErrorDrop.new)

    assert_equal('This is a runtime error: Liquid error (line 1): internal', output)
    assert_equal([Liquid::InternalError], template.errors.map(&:class))
  end

  def test_setting_default_exception_renderer
    exceptions = []
    default_exception_renderer = ->(e) {
      exceptions << e
      ''
    }

    env = Liquid::Environment.build(exception_renderer: default_exception_renderer)
    template = Liquid::Template.parse('This is a runtime error: {{ errors.argument_error }}', environment: env)

    output = template.render('errors' => ErrorDrop.new)

    assert_equal('This is a runtime error: ', output)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  end

  def test_setting_exception_renderer_on_environment
    exceptions = []
    exception_renderer = ->(e) do
      exceptions << e
      ''
    end

    environment = Liquid::Environment.build(exception_renderer: exception_renderer)
    template = Liquid::Template.parse('This is a runtime error: {{ errors.argument_error }}', environment: environment)
    output = template.render('errors' => ErrorDrop.new)

    assert_equal('This is a runtime error: ', output)
    assert_equal([Liquid::ArgumentError], template.errors.map(&:class))
  end

  class TestFileSystem
    def read_template_file(_template_path)
      "{{ errors.argument_error }}"
    end
  end
end

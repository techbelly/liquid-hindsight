# frozen_string_literal: true

require 'test_helper'

class TableRowTest < Minitest::Test
  include Liquid

  class ArrayDrop < Liquid::Drop
    include Enumerable

    def initialize(array)
      @array = array
    end

    def each(&block)
      @array.each(&block)
    end
  end

  def test_blank_string_not_iterable
    assert_template_result(
      "<tr class=\"row1\">\n</tr>\n",
      "{% tablerow char in characters cols:3 %}I WILL NOT BE OUTPUT{% endtablerow %}",
      { 'characters' => '' },
    )
  end

  def test_nil_limit_is_treated_as_zero
    expect = "<tr class=\"row1\">\n" \
      "</tr>\n"

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) limit:nil %}{{ i }}{% endtablerow %}",
    )

    assert_template_result(
      expect,
      "{% tablerow i in (1..2) limit:var %}{{ i }}{% endtablerow %}",
      { "var" => nil },
    )
  end

  def test_table_row_renders_correct_error_message_for_invalid_parameters
    assert_template_result(
      "Liquid error (line 1): invalid integer",
      '{% tablerow n in (1...10) limit:true %} {{n}} {% endtablerow %}',
      error_mode: :warn,
      render_errors: true,
    )

    assert_template_result(
      "Liquid error (line 1): invalid integer",
      '{% tablerow n in (1...10) offset:true %} {{n}} {% endtablerow %}',
      error_mode: :warn,
      render_errors: true,
    )

    assert_template_result(
      "Liquid error (line 1): invalid integer",
      '{% tablerow n in (1...10) cols:true %} {{n}} {% endtablerow %}',
      render_errors: true,
      error_mode: :warn,
    )
  end

  def test_table_row_does_not_leak_interrupts
    template = <<~LIQUID
      {% for i in (1..2) -%}
      {% for j in (1..2) -%}
      {% tablerow k in (1..3) %}{% break %}{% endtablerow -%}
      loop j={{ j }}
      {% endfor -%}
      loop i={{ i }}
      {% endfor -%}
      after loop
    LIQUID

    expected = <<~STR
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=2
      loop i=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=1
      <tr class="row1">
      <td class="col1"></td></tr>
      loop j=2
      loop i=2
      after loop
    STR

    assert_template_result(
      expected,
      template,
    )
  end

  def test_tablerow_without_in_keyword_in_strict2_mode
    template = '{% tablerow i (1..10) %}{{ i }}{% endtablerow %}'

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_equal("Liquid syntax error: For loops require an 'in' clause in \"i (1..10)\"", error.message)
    end
  end

  def test_tablerow_with_multiple_invalid_attributes_reports_first_in_strict2_mode
    template = '{% tablerow i in (1..10) invalid1: 5, invalid2: 10 %}{{ i }}{% endtablerow %}'

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_equal("Liquid syntax error: Invalid attribute 'invalid1' in tablerow loop. Valid attributes are cols, limit, offset, and range in \"i in (1..10) invalid1: 5, invalid2: 10\"", error.message)
    end
  end

  def test_tablerow_with_empty_collection_in_strict2_mode
    template = <<~LIQUID.chomp
      {% tablerow i in empty_array cols: 2 %}{{ i }}{% endtablerow %}
    LIQUID

    expected = <<~OUTPUT
      <tr class="row1">
      </tr>
    OUTPUT

    with_error_modes(:strict2) do
      assert_template_result(expected, template, { 'empty_array' => [] })
    end
  end

  def test_tablerow_with_invalid_expression_strict_vs_strict2
    template = '{% tablerow i in (1..5) limit: foo=>bar %}{{ i }}{% endtablerow %}'

    with_error_modes(:lax, :strict) do
      expected = <<~OUTPUT
        <tr class="row1">
        </tr>
      OUTPUT
      assert_template_result(expected, template)
    end

    with_error_modes(:strict2) do
      error = assert_raises(SyntaxError) { Template.parse(template) }
      assert_match(/Unexpected character =/, error.message)
    end
  end
end

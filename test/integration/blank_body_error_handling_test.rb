# frozen_string_literal: true

require 'test_helper'

class BlankBodyErrorHandlingTest < Minitest::Test
  COMPARISON_ERROR = 'Liquid error (line 1): comparison of Integer with String failed'
  INVALID_INTEGER_ERROR = 'Liquid error (line 1): invalid integer'

  def render_inline(source, error_mode:, assigns: {})
    Liquid::Template.parse(source, line_numbers: true, error_mode: error_mode).render(assigns, render_errors: true)
  end

  def assert_render_raises(source, error_mode:, assigns: {}, message: nil)
    error = assert_raises(Liquid::ArgumentError) do
      Liquid::Template.parse(source, line_numbers: true, error_mode: error_mode).render!(assigns)
    end
    assert_includes(error.message, message) if message
  end

  def test_blank_if_body_suppresses_inline_error_text_in_lax_and_strict
    [:lax, :strict].each do |mode|
      assert_equal('', render_inline('{% if 5 > "x" %}{% endif %}', error_mode: mode))
    end
  end

  def test_blank_unless_body_suppresses_inline_error_text_in_lax_and_strict
    [:lax, :strict].each do |mode|
      assert_equal('', render_inline('{% unless 5 > "x" %} {% endunless %}', error_mode: mode))
    end
  end

  def test_blank_for_body_suppresses_inline_error_text_in_lax_and_strict
    [:lax, :strict].each do |mode|
      assert_equal('', render_inline('{% for i in (1..3) offset: xs %}{% endfor %}', error_mode: mode, assigns: { 'xs' => 'bad' }))
    end
  end

  def test_strict2_blank_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}{% endif %}', error_mode: :strict2))
  end

  def test_strict2_whitespace_if_body_shows_inline_error_text
    assert_equal(COMPARISON_ERROR, render_inline('{% if 5 > "x" %}   {% endif %}', error_mode: :strict2))
  end

  def test_raised_errors_are_not_swallowed_by_blank_if_body
    [:lax, :strict, :strict2].each do |mode|
      assert_render_raises('{% if 5 > "x" %}{% endif %}', error_mode: mode, message: 'comparison of Integer with String failed')
    end
  end

  def test_raised_errors_are_not_swallowed_by_blank_for_body
    [:lax, :strict, :strict2].each do |mode|
      assert_render_raises('{% for i in (1..3) offset: xs %}{% endfor %}', error_mode: mode, assigns: { 'xs' => 'bad' }, message: 'invalid integer')
    end
  end
end

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
end

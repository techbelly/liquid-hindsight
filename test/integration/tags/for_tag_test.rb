# frozen_string_literal: true

require 'test_helper'

class ThingWithValue < Liquid::Drop
  def value
    3
  end
end

class ForTagTest < Minitest::Test
  include Liquid

  def test_limiting_with_invalid_limit
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: true offset: 1 %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_limiting_with_invalid_offset
    assigns  = { 'array' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }
    template = <<-MKUP
      {% for i in array limit: 1 offset: true %}
        {{ i }}
      {% endfor %}
    MKUP

    exception = assert_raises(Liquid::ArgumentError) do
      Template.parse(template).render!(assigns)
    end
    assert_equal("Liquid error: invalid integer", exception.message)
  end

  def test_bad_variable_naming_in_for_loop
    assert_raises(Liquid::SyntaxError) do
      Liquid::Template.parse('{% for a/b in x %}{% endfor %}')
    end
  end

  class LoaderDrop < Liquid::Drop
    attr_accessor :each_called, :load_slice_called

    def initialize(data)
      @data = data
    end

    def each
      @each_called = true
    end

    def load_slice(from, to)
      @load_slice_called = true
      @data[(from..to - 1)]
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class ForTagUnitTest < Minitest::Test
  def test_for_nodelist
    template = Liquid::Template.parse('{% for item in items %}FOR{% endfor %}')
    assert_equal(['FOR'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end
end

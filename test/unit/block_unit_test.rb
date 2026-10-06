# frozen_string_literal: true

require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Liquid

  def test_blankspace
    template = Liquid::Template.parse("  ")
    assert_equal(["  "], template.root.nodelist)
  end

  def test_variable_beginning
    template = Liquid::Template.parse("{{funk}}  ")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(Variable, template.root.nodelist[0].class)
    assert_equal(String, template.root.nodelist[1].class)
  end

  def test_variable_end
    template = Liquid::Template.parse("  {{funk}}")
    assert_equal(2, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
  end

  def test_variable_middle
    template = Liquid::Template.parse("  {{funk}}  ")
    assert_equal(3, template.root.nodelist.size)
    assert_equal(String, template.root.nodelist[0].class)
    assert_equal(Variable, template.root.nodelist[1].class)
    assert_equal(String, template.root.nodelist[2].class)
  end

  private

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end

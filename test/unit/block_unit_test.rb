# frozen_string_literal: true

require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Liquid

  def test_blankspace
    template = Liquid::Template.parse("  ")
    assert_equal(["  "], template.root.nodelist)
  end

  private

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end

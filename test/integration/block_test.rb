# frozen_string_literal: true

require 'test_helper'

class BlockTest < Minitest::Test
  include Liquid

  def test_with_custom_tag
    with_custom_tag('testtag', Block) do
      assert(Liquid::Template.parse("{% testtag %} {% endtesttag %}"))
    end
  end
end

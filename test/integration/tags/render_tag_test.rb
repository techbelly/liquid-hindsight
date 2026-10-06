# frozen_string_literal: true

require 'test_helper'

class RenderTagTest < Minitest::Test
  include Liquid

  def test_dynamically_choosen_templates_are_not_allowed
    assert_syntax_error("{% assign name = 'snippet' %}{% render name %}")
  end
end

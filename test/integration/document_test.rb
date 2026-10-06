# frozen_string_literal: true

require 'test_helper'

class DocumentTest < Minitest::Test
  include Liquid

  def test_unknown_tag
    source = "{% foo %}"
    assert_match_syntax_error("Liquid syntax error (line 1): Unknown tag 'foo'", source)
  end
end

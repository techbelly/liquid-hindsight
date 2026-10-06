# frozen_string_literal: true

require 'test_helper'

class BlockTest < Minitest::Test
  include Liquid

  def test_unexpected_end_tag
    source = '{% if true %}{% endunless %}'
    assert_match_syntax_error("Liquid syntax error (line 1): 'endunless' is not a valid delimiter for if tags. use endif", source)
  end

  def test_with_custom_tag
    with_custom_tag('testtag', Block) do
      assert(Liquid::Template.parse("{% testtag %} {% endtesttag %}"))
    end
  end
end

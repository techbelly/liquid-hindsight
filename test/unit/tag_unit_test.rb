# frozen_string_literal: true

require 'test_helper'

class TagUnitTest < Minitest::Test
  include Liquid

  def test_tag_name_should_return_name_of_the_tag
    tag = Tag.parse("some_tag", "", new_tokenizer, ParseContext.new)
    assert_equal('some_tag', tag.tag_name)
  end

  class CustomTag < Liquid::Tag
    def render(_context); end
  end

  private

  def new_tokenizer
    Tokenizer.new(
      source: "",
      string_scanner: StringScanner.new(""),
    )
  end
end

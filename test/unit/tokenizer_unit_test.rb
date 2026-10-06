# frozen_string_literal: true

require 'test_helper'

class TokenizerTest < Minitest::Test
  def test_tokenize_with_nil_source_returns_empty_array
    assert_equal([], tokenize(nil))
  end

  private

  def new_tokenizer(source, parse_context: Liquid::ParseContext.new, start_line_number: nil)
    parse_context.new_tokenizer(source, start_line_number: start_line_number)
  end

  def tokenize(source)
    tokenizer = new_tokenizer(source)
    tokens    = []
    # shift is private in Liquid::C::Tokenizer, since it is only for unit testing
    while (t = tokenizer.send(:shift))
    end
    tokens
  end

  def tokenize_line_numbers(source)
    tokenizer    = new_tokenizer(source, start_line_number: 1)
    line_numbers = []
    line_numbers
  end
end

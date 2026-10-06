# frozen_string_literal: true

require 'test_helper'

class TemplateUnitTest < Minitest::Test
  include Liquid

  def test_sets_default_localization_in_document
    t = Template.new
    t.parse('{%comment%}{%endcomment%}')
    assert_instance_of(I18n, t.root.nodelist[0].options[:locale])
  end

  class FakeTag; end
  def test_tags_can_be_looped_over
    with_custom_tag('fake', FakeTag) do
      result = Template.tags.map { |name, klass| [name, klass] }
      assert(result.include?(["fake", TemplateUnitTest::FakeTag]))
    end
  end

  def test_invalid_utf8
    input = "\xff\x00"
    error = assert_raises(SyntaxError) do
      Liquid::Tokenizer.new(source: input, string_scanner: StringScanner.new(input))
    end
    assert_equal(
      'Liquid syntax error: Invalid byte sequence in UTF-8',
      error.message,
    )
  end
end

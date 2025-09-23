# frozen_string_literal: true

require 'test_helper'

class TemplateUnitTest < Minitest::Test
  include Liquid

  class FakeTag; end
  def test_tags_can_be_looped_over
    with_custom_tag('fake', FakeTag) do
      result = Template.tags.map { |name, klass| [name, klass] }
      assert(result.include?(["fake", TemplateUnitTest::FakeTag]))
    end
  end
end

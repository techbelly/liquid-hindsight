# frozen_string_literal: true

require 'test_helper'

class I18nUnitTest < Minitest::Test
  include Liquid

  def setup
    @i18n = I18n.new(fixture("en_locale.yml"))
  end

  def test_raises_unknown_translation
    assert_raises(I18n::TranslationError) do
      @i18n.translate("doesnt_exist")
    end
  end

  def test_sets_default_path_to_en
    assert_equal(I18n::DEFAULT_LOCALE, I18n.new.path)
  end
end

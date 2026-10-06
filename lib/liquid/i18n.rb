# frozen_string_literal: true

require 'yaml'

module Liquid
  class I18n
    DEFAULT_LOCALE = File.join(File.expand_path(__dir__), "locales", "en.yml")

    TranslationError = Class.new(StandardError)

    attr_reader :path

    def initialize(path = DEFAULT_LOCALE)
      @path = path
    end

    private
  end
end

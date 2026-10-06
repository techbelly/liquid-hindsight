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

    def translate(name, vars = {})
      interpolate(deep_fetch_translation(name), vars)
    end
    alias_method :t, :translate

    def locale
      @locale ||= YAML.load_file(@path)
    end

    private

    def deep_fetch_translation(name)
      name.split('.').reduce(locale) do |level, cur|
        level[cur] || raise(TranslationError, "Translation for #{name} does not exist in locale #{path}")
      end
    end
  end
end

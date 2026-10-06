# frozen_string_literal: true

module Liquid
  class ParseContext
    attr_accessor :locale, :line_number, :trim_whitespace, :depth
    attr_reader :partial, :warnings, :error_mode, :environment
  end
end

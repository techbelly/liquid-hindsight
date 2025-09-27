# frozen_string_literal: true

module Liquid
  class ParseContext
    attr_reader :locale, :line_number
    attr_reader :error_mode
  end
end

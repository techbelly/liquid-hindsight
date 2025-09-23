# frozen_string_literal: true

module Liquid
  class Template
    attr_accessor :root, :name

    class << self
      def tags
        Environment.default.tags
      end
    end

    private
  end
end

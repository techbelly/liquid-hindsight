# frozen_string_literal: true

module Liquid
  class Include < Tag
    prepend Tag::Disableable

    def parse(_tokens)
    end

    alias_method :parse_context, :options
    private :parse_context
  end
end

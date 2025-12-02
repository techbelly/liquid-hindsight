# frozen_string_literal: true

module Liquid
  class Include < Tag
    prepend Tag::Disableable

    FOR = 'for'
    SYNTAX = /(#{QuotedFragment}+)(\s+(with|#{FOR})\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o
    Syntax = SYNTAX

    def parse(_tokens)
    end

    alias_method :parse_context, :options
    private :parse_context
  end
end

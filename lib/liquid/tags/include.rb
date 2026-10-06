# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name include
  # @liquid_summary
  #   Renders a [snippet](/themes/architecture/snippets).
  # @liquid_description
  #   Inside the snippet, you can access and alter variables that are [created](/docs/api/liquid/tags/variable-tags) outside of the
  #   snippet.
  # @liquid_syntax
  #   {% include 'filename' %}
  # @liquid_syntax_keyword filename The name of the snippet to render, without the `.liquid` extension.
  # @liquid_deprecated
  #   Deprecated because the way that variables are handled reduces performance and makes code harder to both read and maintain.
  #
  #   The `include` tag has been replaced by [`render`](/docs/api/liquid/tags/render).
  class Include < Tag
    prepend Tag::Disableable

    FOR = 'for'
    SYNTAX = /(#{QuotedFragment}+)(\s+(with|#{FOR})\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o
    Syntax = SYNTAX

    attr_reader :template_name_expr, :variable_name_expr, :attributes

    def parse(_tokens)
    end

    alias_method :parse_context, :options
    private :parse_context
  end
end

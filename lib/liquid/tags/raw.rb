# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name raw
  # @liquid_summary
  #   Outputs any Liquid code as text instead of rendering it.
  # @liquid_syntax
  #   {% raw %}
  #     expression
  #   {% endraw %}
  # @liquid_syntax_keyword expression The expression to be output without being rendered.
  class Raw < Block
    Syntax = /\A\s*\z/

    protected
  end
end

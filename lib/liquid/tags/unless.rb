# frozen_string_literal: true

require_relative 'if'

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category conditional
  # @liquid_name unless
  # @liquid_summary
  #   Renders an expression unless a specific condition is `true`.
  # @liquid_description
  #   > Tip:
  #   > Similar to the [`if` tag](/docs/api/liquid/tags/if), you can use `elsif` to add more conditions to an `unless` tag.
  # @liquid_syntax
  #   {% unless condition %}
  #     expression
  #   {% endunless %}
  # @liquid_syntax_keyword condition The condition to evaluate.
  # @liquid_syntax_keyword expression The expression to render unless the condition is met.
  class Unless < If
  end
end

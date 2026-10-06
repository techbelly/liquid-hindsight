# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name doc
  # @liquid_summary
  #   Documents template elements with annotations.
  # @liquid_description
  #   The `doc` tag allows developers to include documentation within Liquid
  #   templates. Any content inside `doc` tags is not rendered or outputted.
  #   Liquid code inside will be parsed but not executed. This facilitates
  #   tooling support for features like code completion, linting, and inline
  #   documentation.
  #
  #   For detailed documentation syntax and examples, see the
  #   [`LiquidDoc` reference](/docs/storefronts/themes/tools/liquid-doc).
  #
  # @liquid_syntax
  #   {% doc %}
  #     Renders a message.
  #
  #     @param {string} foo - A string value.
  #     @param {string} [bar] - An optional string value.
  #
  #     @example
  #     {% render 'message', foo: 'Hello', bar: 'World' %}
  #   {% enddoc %}
  class Doc < Block
    NO_UNEXPECTED_ARGS = /\A\s*\z/

    private
  end
end

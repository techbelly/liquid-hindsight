# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category theme
  # @liquid_name render
  # @liquid_summary
  #   Renders a [snippet](/themes/architecture/snippets) or [app block](/themes/architecture/sections/section-schema#render-app-blocks).
  # @liquid_description
  #   Inside snippets and app blocks, you can't directly access variables that are [created](/docs/api/liquid/tags/variable-tags) outside
  #   of the snippet or app block. However, you can [specify variables as parameters](/docs/api/liquid/tags/render#render-passing-variables-to-a-snippet)
  #   to pass outside variables to snippets.
  #
  #   While you can't directly access created variables, you can access global objects, as well as any objects that are
  #   directly accessible outside the snippet or app block. For example, a snippet or app block inside the [product template](/themes/architecture/templates/product)
  #   can access the [`product` object](/docs/api/liquid/objects/product), and a snippet or app block inside a [section](/themes/architecture/sections)
  #   can access the [`section` object](/docs/api/liquid/objects/section).
  #
  #   Outside a snippet or app block, you can't access variables created inside the snippet or app block.
  #
  #   > Note:
  #   > When you render a snippet using the `render` tag, you can't use the [`include` tag](/docs/api/liquid/tags/include)
  #   > inside the snippet.
  # @liquid_syntax
  #   {% render 'filename' %}
  # @liquid_syntax_keyword filename The name of the snippet to render, without the `.liquid` extension.
  class Render < Tag
    FOR = 'for'
    SYNTAX = /(#{QuotedString}+)(\s+(with|#{FOR})\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o

    disable_tags "include"

    attr_reader :template_name_expr, :variable_name_expr, :attributes, :alias_name
  end
end

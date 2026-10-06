# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name continue
  # @liquid_summary
  #   Causes a [`for` loop](/docs/api/liquid/tags/for) to skip to the next iteration.
  # @liquid_syntax
  #   {% continue %}
  class Continue < Tag
    INTERRUPT = ContinueInterrupt.new.freeze
  end
end

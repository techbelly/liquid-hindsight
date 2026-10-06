# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type object
  # @liquid_name forloop
  # @liquid_summary
  #   Information about a parent [`for` loop](/docs/api/liquid/tags/for).
  class ForloopDrop < Drop
    # @liquid_public_docs
    # @liquid_name length
    # @liquid_summary
    #   The total number of iterations in the loop.
    # @liquid_return [number]
    attr_reader :length

    # @liquid_public_docs
    # @liquid_name parentloop
    # @liquid_summary
    #   The parent `forloop` object.
    # @liquid_description
    #   If the current `for` loop isn't nested inside another `for` loop, then `nil` is returned.
    # @liquid_return [forloop]
    attr_reader :parentloop

    attr_reader :name

    # @liquid_public_docs
    # @liquid_summary
    #   Returns `true` if the current iteration is the first. Returns `false` if not.
    # @liquid_return [boolean]
    def first
      @index == 0
    end

    # @liquid_public_docs
    # @liquid_summary
    #   Returns `true` if the current iteration is the last. Returns `false` if not.
    # @liquid_return [boolean]
    def last
      @index == @length - 1
    end

    protected
  end
end

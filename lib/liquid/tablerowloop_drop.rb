# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type object
  # @liquid_name tablerowloop
  # @liquid_summary
  #   Information about a parent [`tablerow` loop](/docs/api/liquid/tags/tablerow).
  class TablerowloopDrop < Drop
    # @liquid_public_docs
    # @liquid_summary
    #   The total number of iterations in the loop.
    # @liquid_return [number]
    attr_reader :length

    # @liquid_public_docs
    # @liquid_summary
    #   The 1-based index of the current column.
    # @liquid_return [number]
    attr_reader :col

    # @liquid_public_docs
    # @liquid_summary
    #   The 1-based index of current row.
    # @liquid_return [number]
    attr_reader :row

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

    def increment!
      @index += 1

      if @col == @cols
        @col = 1
        @row += 1
      else
        @col += 1
      end
    end
  end
end

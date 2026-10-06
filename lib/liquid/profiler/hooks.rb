# frozen_string_literal: true

module Liquid
  module BlockBodyProfilingHook
  end
  BlockBody.prepend(BlockBodyProfilingHook)

  module DocumentProfilingHook
  end
  Document.prepend(DocumentProfilingHook)

  module ContextProfilingHook
    attr_accessor :profiler

    def new_isolated_subcontext
      new_context = super
      new_context.profiler = profiler
      new_context
    end
  end
  Context.prepend(ContextProfilingHook)
end

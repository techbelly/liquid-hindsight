# frozen_string_literal: true

module Liquid
  module BlockBodyProfilingHook
    def render_node(context, output, node)
      super
    end
  end
  BlockBody.prepend(BlockBodyProfilingHook)

  module DocumentProfilingHook
    def render_to_output_buffer(context, output)
      return super unless context.profiler
    end
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

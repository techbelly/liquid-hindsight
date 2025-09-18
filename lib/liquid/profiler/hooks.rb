# frozen_string_literal: true

module Liquid
  module BlockBodyProfilingHook
  end
  BlockBody.prepend(BlockBodyProfilingHook)

  module DocumentProfilingHook
  end
  Document.prepend(DocumentProfilingHook)

  module ContextProfilingHook
  end
  Context.prepend(ContextProfilingHook)
end

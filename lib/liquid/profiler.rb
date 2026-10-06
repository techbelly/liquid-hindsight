# frozen_string_literal: true

require 'liquid/profiler/hooks'

module Liquid
  # Profiler enables support for profiling template rendering to help track down performance issues.
  #
  # To enable profiling, first require 'liquid/profiler'.
  # Then, to profile a parse/render cycle, pass the <tt>profile: true</tt> option to <tt>Liquid::Template.parse</tt>.
  # After <tt>Liquid::Template#render</tt> is called, the template object makes available an instance of this
  # class via the <tt>Liquid::Template#profiler</tt> method.
  #
  #   template = Liquid::Template.parse(template_content, profile: true)
  #   output  = template.render
  #   profile = template.profiler
  #
  # This object contains all profiling information, containing information on what tags were rendered,
  # where in the templates these tags live, and how long each tag took to render.
  #
  # This is a tree structure that is Enumerable all the way down, and keeps track of tags and rendering times
  # inside of <tt>{% include %}</tt> tags.
  #
  #   profile.each do |node|
  #     # Access to the node itself
  #     node.code
  #
  #     # Which template and line number of this node.
  #     # The top-level template name is `nil` by default, but can be set in the Liquid::Context before rendering.
  #     node.partial
  #     node.line_number
  #
  #     # Render time in seconds of this node
  #     node.render_time
  #
  #     # If the template used {% include %}, this node will also have children.
  #     node.children.each do |child2|
  #       # ...
  #     end
  #   end
  #
  # Profiler also exposes the total time of the template's render in <tt>Liquid::Profiler#total_render_time</tt>.
  #
  # All render times are in seconds. There is a small performance hit when profiling is enabled.
  #
  class Profiler
    include Enumerable

    attr_reader :total_time
    alias_method :total_render_time, :total_time

    def [](idx)
      children[idx]
    end

    private
  end
end

# frozen_string_literal: true

require 'test_helper'

class ProfilerTest < Minitest::Test
  class TestDrop < Liquid::Drop
    def initialize(value)
      super()
      @value = value
    end

    def to_s
      artificial_execution_time

      @value
    end

    private

    # Monotonic clock precision fluctuate based on the operating system
    # By introducing a small sleep we ensure ourselves to register a non zero unit of time
    def artificial_execution_time
      sleep(Process.clock_getres(Process::CLOCK_MONOTONIC))
    end
  end

  include Liquid

  class ProfilingFileSystem
    def read_template_file(template_path)
      "Rendering template {% assign template_name = '#{template_path}'%}\n{{ template_name }}"
    end
  end

  def setup
    Liquid::Environment.default.file_system = ProfilingFileSystem.new
  end

  def test_template_allows_flagging_profiling
    t = Template.parse("{{ 'a string' | upcase }}")
    t.render!

    assert_nil(t.profiler)
  end

  def test_profiling_times_the_entire_render
    t = Template.parse("{% include 'a_template' %}", profile: true)
    t.render!

    assert(t.profiler.total_render_time >= 0, "Total render time was not calculated")
  end

  class SleepTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @duration = Float(markup)
    end

    def render_to_output_buffer(_context, _output)
      sleep(@duration)
    end
  end

  def test_profiling_multiple_renders
    with_custom_tag('sleep', SleepTag) do
      context = Liquid::Context.new
      t = Liquid::Template.parse("{% sleep 0.001 %}", profile: true)
      context.template_name = 'index'
      t.render!(context)
      context.template_name = 'layout'
      first_render_time = context.profiler.total_time
      t.render!(context)

      profiler = context.profiler
      children = profiler.children
      assert_operator(first_render_time, :>=, 0.001)
      assert_operator(profiler.total_time, :>=, 0.001 + first_render_time)
      assert_equal(["index", "layout"], children.map(&:template_name))
      assert_equal([nil, nil], children.map(&:code))
      assert_equal(profiler.total_time, children.map(&:total_time).reduce(&:+))
    end
  end

  def test_profiling_uses_include_to_mark_children
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}", profile: true)
    t.render!

    include_node = t.profiler[1]
    assert_equal(2, include_node.children.length)
  end

  def test_profiling_marks_children_with_the_name_of_included_partial
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}", profile: true)
    t.render!

    include_node = t.profiler[1]
    include_node.children.each do |child|
      assert_equal("a_template", child.partial)
    end
  end

  def test_profiling_supports_multiple_templates
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}\n{% include 'b_template' %}", profile: true)
    t.render!

    a_template = t.profiler[1]
    a_template.children.each do |child|
      assert_equal("a_template", child.partial)
    end

    b_template = t.profiler[2]
    b_template.children.each do |child|
      assert_equal("b_template", child.partial)
    end
  end

  def test_profiling_supports_rendering_the_same_partial_multiple_times
    t = Template.parse("{{ 'a string' | upcase }}\n{% include 'a_template' %}\n{% include 'a_template' %}", profile: true)
    t.render!

    a_template1 = t.profiler[1]
    a_template1.children.each do |child|
      assert_equal("a_template", child.partial)
    end

    a_template2 = t.profiler[2]
    a_template2.children.each do |child|
      assert_equal("a_template", child.partial)
    end
  end
end

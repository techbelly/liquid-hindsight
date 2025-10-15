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

  class SleepTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @duration = Float(markup)
    end

    def render_to_output_buffer(_context, _output)
      sleep(@duration)
    end
  end
end

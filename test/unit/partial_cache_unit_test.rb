# frozen_string_literal: true

require 'test_helper'

class PartialCacheUnitTest < Minitest::Test
  def test_reads_from_the_file_system_only_once_per_file
    file_system = StubFileSystem.new('my_partial' => 'some partial body')
    context     = Liquid::Context.build(
      registers: { file_system: file_system },
    )

    2.times do
      Liquid::PartialCache.load(
        'my_partial',
        context: context,
        parse_context: Liquid::ParseContext.new,
      )
    end

    assert_equal(1, file_system.file_read_count)
  end
end

# frozen_string_literal: true

require 'test_helper'

class FileSystemUnitTest < Minitest::Test
  include Liquid

  def test_default
    assert_raises(FileSystemError) do
      BlankFileSystem.new.read_template_file("dummy")
    end
  end
end

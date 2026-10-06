# frozen_string_literal: true

require 'test_helper'

class HashRenderingTest < Minitest::Test
  def test_rendering_hash_with_custom_to_s_method_uses_custom_to_s
    assert_template_result("kewl", "{{ my_hash }}", { "my_hash" => HashWithCustomToS.new })
  end
end

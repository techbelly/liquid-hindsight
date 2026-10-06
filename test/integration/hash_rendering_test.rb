# frozen_string_literal: true

require 'test_helper'

class HashRenderingTest < Minitest::Test
  def test_render_empty_hash
    assert_template_result("{}", "{{ my_hash }}", { "my_hash" => {} })
  end

  def test_join_filter_with_hash
    array = [{ "key1" => "value1" }, { "key2" => "value2" }]
    glue = { "lol" => "wut" }
    assert_template_result("{\"key1\"=>\"value1\"}{\"lol\"=>\"wut\"}{\"key2\"=>\"value2\"}", "{{ my_array | join: glue }}", { "my_array" => array, "glue" => glue })
  end

  def test_rendering_hash_with_custom_to_s_method_uses_custom_to_s
    assert_template_result("kewl", "{{ my_hash }}", { "my_hash" => HashWithCustomToS.new })
  end
end

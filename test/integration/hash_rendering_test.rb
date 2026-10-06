# frozen_string_literal: true

require 'test_helper'

class HashRenderingTest < Minitest::Test
  def test_render_empty_hash
    assert_template_result("{}", "{{ my_hash }}", { "my_hash" => {} })
  end

  def test_hash_with_replace___key____replaced_key__filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | replace: 'key', 'replaced_key' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_append____appended_text__filter
    assert_template_result("{\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"} appended text", "{{ my_hash | append: ' appended text' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_hash_with_prepend___prepended_text___filter
    assert_template_result("prepended text {\"Key\"=>\"Value\", \"AnotherKey\"=>\"AnotherValue\"}", "{{ my_hash | prepend: 'prepended text ' }}", { "my_hash" => { "Key" => "Value", "AnotherKey" => "AnotherValue" } })
  end

  def test_join_filter_with_hash
    array = [{ "key1" => "value1" }, { "key2" => "value2" }]
    glue = { "lol" => "wut" }
    assert_template_result("{\"key1\"=>\"value1\"}{\"lol\"=>\"wut\"}{\"key2\"=>\"value2\"}", "{{ my_array | join: glue }}", { "my_array" => array, "glue" => glue })
  end

  def test_rendering_hash_with_custom_to_s_method_uses_custom_to_s
    assert_template_result("kewl", "{{ my_hash }}", { "my_hash" => HashWithCustomToS.new })
  end

  def test_rendering_hash_without_custom_to_s_uses_default_inspect
    my_hash = HashWithoutCustomToS.new
    my_hash[:foo] = :bar

    assert_template_result("{:foo=>:bar}", "{{ my_hash }}", { "my_hash" => my_hash })
  end
end

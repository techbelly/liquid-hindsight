# frozen_string_literal: true

require 'test_helper'

class SelfDropContextTest < Minitest::Test
  include Liquid

  def test_self_drop_reflects_variables_assigned_after_creation
    source = <<~LIQUID
      {%- assign s = self -%}
      {%- assign x = 42 %}{{ s.x -}}
    LIQUID

    assert_template_result('42', source)
  end

  def test_self_drop_context_setter_is_undefined
    context = Context.new
    drop = SelfDrop.new(context)
    refute(drop.respond_to?(:context=))

    assert_template_result('42', '{{ self.x }}', { 'x' => 42 })
  end

  def test_self_drop_repeated_lookups_compare_equal_for_same_context
    context = Context.new
    drop = context.find_variable("self")
    cached_drop = context.find_variable("self")

    assert_same(drop, cached_drop)
    assert_equal(drop.object_id, cached_drop.object_id)
    assert_equal(drop, cached_drop)
  end

  def test_assigned_self_drop_compares_equal_to_itself
    assert_template_result('T', '{% assign s = self %}{% if s == s %}T{% else %}F{% endif %}')
  end

  def test_bare_self_compares_equal_to_bare_self
    assert_template_result('T', '{% if self == self %}T{% else %}F{% endif %}')
  end

  def test_self_drop_can_be_passed_as_bare_drop_to_render
    t = Template.parse('{{ self.x }}')
    drop = SelfDrop.new(Context.new({ 'x' => 42 }))
    result = t.render(drop)
    assert_equal('42', result)
  end
end

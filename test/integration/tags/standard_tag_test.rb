# frozen_string_literal: true

require 'test_helper'

class StandardTagTest < Minitest::Test
  include Liquid

  def test_no_transform
    assert_template_result(
      'this text should come out of the template without change...',
      'this text should come out of the template without change...',
    )

    assert_template_result('blah', 'blah')
    assert_template_result('<blah>', '<blah>')
    assert_template_result('|,.:', '|,.:')
    assert_template_result('', '')

    text = %(this shouldnt see any transformation either but has multiple lines
              as you can clearly see here ...)
    assert_template_result(text, text)
  end

  def test_has_a_block_which_does_nothing
    assert_template_result(
      %(the comment block should be removed  .. right?),
      %(the comment block should be removed {%comment%} be gone.. {%endcomment%} .. right?),
    )

    assert_template_result('', '{%comment%}{%endcomment%}')
    assert_template_result('', '{%comment%}{% endcomment %}')
    assert_template_result('', '{% comment %}{%endcomment%}')
    assert_template_result('', '{% comment %}{% endcomment %}')
    assert_template_result('', '{%comment%}comment{%endcomment%}')
    assert_template_result('', '{% comment %}comment{% endcomment %}')
    assert_template_result('', '{% comment %} 1 {% comment %} 2 {% endcomment %} 3 {% endcomment %}')

    assert_template_result('', '{%comment%}{%blabla%}{%endcomment%}')
    assert_template_result('', '{% comment %}{% blabla %}{% endcomment %}')
    assert_template_result('', '{%comment%}{% endif %}{%endcomment%}')
    assert_template_result('', '{% comment %}{% endwhatever %}{% endcomment %}')
    assert_template_result('', '{% comment %}{% raw %} {{%%%%}}  }} { {% endcomment %} {% comment {% endraw %} {% endcomment %}')
    assert_template_result('', '{% comment %}{% " %}{% endcomment %}')
    assert_template_result('', '{% comment %}{%%}{% endcomment %}')

    assert_template_result('foobar', 'foo{%comment%}comment{%endcomment%}bar')
    assert_template_result('foobar', 'foo{% comment %}comment{% endcomment %}bar')
    assert_template_result('foobar', 'foo{%comment%} comment {%endcomment%}bar')
    assert_template_result('foobar', 'foo{% comment %} comment {% endcomment %}bar')

    assert_template_result('foo  bar', 'foo {%comment%} {%endcomment%} bar')
    assert_template_result('foo  bar', 'foo {%comment%}comment{%endcomment%} bar')
    assert_template_result('foo  bar', 'foo {%comment%} comment {%endcomment%} bar')

    assert_template_result('foobar', 'foo{%comment%}
                                     {%endcomment%}bar')
  end

  def test_assign_with_colon_and_spaces
    assigns = { 'var' => { 'a:b c' => { 'paged' => '1' } } }
    assert_template_result('var2: 1', '{%assign var2 = var["a:b c"].paged %}var2: {{var2}}', assigns)
  end

  def test_capture_detects_bad_syntax
    assert_raises(SyntaxError) do
      assert_template_result(
        'content foo content foo ',
        '{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}',
        { 'var' => 'content' },
      )
    end
  end

  def test_assign
    assert_template_result('variable', '{% assign a = "variable"%}{{a}}')
  end

  def test_case_detects_bad_syntax
    assert_raises(SyntaxError) do
      assert_template_result('',  '{% case false %}{% when %}true{% endcase %}', {})
    end

    assert_raises(SyntaxError) do
      assert_template_result('',  '{% case false %}{% huh %}true{% endcase %}', {})
    end
  end

  def test_size_of_array
    assigns = { "array" => [1, 2, 3, 4] }
    assert_template_result('array has 4 elements', "array has {{ array.size }} elements", assigns)
  end

  def test_size_of_hash
    assigns = { "hash" => { a: 1, b: 2, c: 3, d: 4 } }
    assert_template_result('hash has 4 elements', "hash has {{ hash.size }} elements", assigns)
  end

  def test_illegal_symbols
    assert_template_result('', '{% if true == empty %}?{% endif %}', {})
    assert_template_result('', '{% if true == null %}?{% endif %}', {})
    assert_template_result('', '{% if empty == true %}?{% endif %}', {})
    assert_template_result('', '{% if null == true %}?{% endif %}', {})
  end
end # StandardTagTest

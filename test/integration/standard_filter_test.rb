# encoding: utf-8
# frozen_string_literal: true

require 'test_helper'

class TestThing
  def initialize
    @foo = 0
  end

  def to_s
    "woot: #{@foo}"
  end

  def [](_whatever)
    to_s
  end

  def to_liquid
    @foo += 1
    self
  end
end

class TestDrop < Liquid::Drop
  def initialize(value:)
    @value = value
  end

  def registers
    "{#{@value.inspect}=>#{@context.registers[@value].inspect}}"
  end
end

class TestModel
  def initialize(value:)
    @value = value
  end

  def to_liquid
    TestDrop.new(value: @value)
  end
end

class TestEnumerable < Liquid::Drop
  include Enumerable

  def each(&block)
    [{ "foo" => 1, "bar" => 2 }, { "foo" => 2, "bar" => 1 }, { "foo" => 3, "bar" => 3 }].each(&block)
  end
end

class NumberLikeThing < Liquid::Drop
  def initialize(amount)
    @amount = amount
  end

  def to_number
    @amount
  end
end

class StandardFiltersTest < Minitest::Test
  Filters = Class.new(Liquid::StrainerTemplate)
  Filters.add_filter(Liquid::StandardFilters)

  include Liquid

  def setup
    @filters = Filters.new(Context.new)
  end

  def test_size
    assert_equal(3, @filters.size([1, 2, 3]))
    assert_equal(0, @filters.size([]))
    assert_equal(0, @filters.size(nil))
  end

  def test_downcase
    assert_equal('testing', @filters.downcase("Testing"))
    assert_equal('', @filters.downcase(nil))
  end

  def test_upcase
    assert_equal('TESTING', @filters.upcase("Testing"))
    assert_equal('', @filters.upcase(nil))
  end

  def test_find_on_empty_array
    assert_nil(@filters.find([], 'foo', 'bar'))
  end

  def test_find_index_on_empty_array
    assert_nil(@filters.find_index([], 'foo', 'bar'))
  end

  def test_has_on_empty_array
    refute(@filters.has([], 'foo', 'bar'))
  end

  def test_split
    assert_equal(['12', '34'], @filters.split('12~34', '~'))
    assert_equal(['A? ', ' ,Z'], @filters.split('A? ~ ~ ~ ,Z', '~ ~ ~'))
    assert_equal(['A?Z'], @filters.split('A?Z', '~'))
    assert_equal([], @filters.split(nil, ' '))
    assert_equal(['A', 'Z'], @filters.split('A1Z', 1))
  end

  def test_escape
    assert_equal('&lt;strong&gt;', @filters.escape('<strong>'))
    assert_equal('1', @filters.escape(1))
    assert_equal('2001-02-03', @filters.escape(Date.new(2001, 2, 3)))
    assert_nil(@filters.escape(nil))
  end

  def test_h
    assert_equal('&lt;strong&gt;', @filters.h('<strong>'))
    assert_equal('1', @filters.h(1))
    assert_equal('2001-02-03', @filters.h(Date.new(2001, 2, 3)))
    assert_nil(@filters.h(nil))
  end

  def test_escape_once
    assert_equal('&lt;strong&gt;Hulk&lt;/strong&gt;', @filters.escape_once('&lt;strong&gt;Hulk</strong>'))
  end

  def test_base64_encode
    assert_equal('b25lIHR3byB0aHJlZQ==', @filters.base64_encode('one two three'))
    assert_equal('', @filters.base64_encode(nil))
  end

  def test_base64_url_safe_encode
    assert_equal(
      'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXogQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVogMTIzNDU2Nzg5MCAhQCMkJV4mKigpLT1fKy8_Ljo7W117fVx8',
      @filters.base64_url_safe_encode('abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890 !@#$%^&*()-=_+/?.:;[]{}\|'),
    )
    assert_equal('', @filters.base64_url_safe_encode(nil))
  end

  def test_url_encode
    assert_equal('foo%2B1%40example.com', @filters.url_encode('foo+1@example.com'))
    assert_equal('1', @filters.url_encode(1))
    assert_equal('2001-02-03', @filters.url_encode(Date.new(2001, 2, 3)))
    assert_nil(@filters.url_encode(nil))
  end

  def test_url_decode
    assert_equal('foo bar', @filters.url_decode('foo+bar'))
    assert_equal('foo bar', @filters.url_decode('foo%20bar'))
    assert_equal('foo+1@example.com', @filters.url_decode('foo%2B1%40example.com'))
    assert_equal('1', @filters.url_decode(1))
    assert_equal('2001-02-03', @filters.url_decode(Date.new(2001, 2, 3)))
    assert_nil(@filters.url_decode(nil))
    exception = assert_raises(Liquid::ArgumentError) do
      @filters.url_decode('%ff')
    end
    assert_equal('Liquid error: invalid byte sequence in UTF-8', exception.message)
  end

  def test_strip_html
    assert_equal('test', @filters.strip_html("<div>test</div>"))
    assert_equal('test', @filters.strip_html("<div id='test'>test</div>"))
    assert_equal('', @filters.strip_html("<script type='text/javascript'>document.write('some stuff');</script>"))
    assert_equal('', @filters.strip_html("<style type='text/css'>foo bar</style>"))
    assert_equal('test', @filters.strip_html("<div\nclass='multiline'>test</div>"))
    assert_equal('test', @filters.strip_html("<!-- foo bar \n test -->test"))
    assert_equal('', @filters.strip_html(nil))

    assert_equal('foo;', @filters.strip_html("<<<script </script>script>foo;</script>"))
  end

  def test_sort_empty_array
    assert_equal([], @filters.sort([], "a"))
  end

  def test_sort_invalid_property
    foo = [
      [1],
      [2],
      [3],
    ]

    assert_raises(Liquid::ArgumentError) do
      @filters.sort(foo, "bar")
    end
  end

  def test_sort_natural_empty_array
    assert_equal([], @filters.sort_natural([], "a"))
  end

  def test_legacy_sort_hash
    assert_equal([{ a: 1, b: 2 }], @filters.sort(a: 1, b: 2))
  end

  def test_uniq_empty_array
    assert_equal([], @filters.uniq([], "a"))
  end

  def test_compact_empty_array
    assert_equal([], @filters.compact([], "a"))
  end

  def test_compact_invalid_property
    foo = [
      [1],
      [2],
      [3],
    ]

    assert_raises(Liquid::ArgumentError) do
      @filters.compact(foo, "bar")
    end
  end

  def test_reverse
    assert_equal([4, 3, 2, 1], @filters.reverse([1, 2, 3, 4]))
  end

  def test_legacy_reverse_hash
    assert_equal([{ a: 1, b: 2 }], @filters.reverse(a: 1, b: 2))
  end

  def test_first_last
    assert_equal(1, @filters.first([1, 2, 3]))
    assert_equal(3, @filters.last([1, 2, 3]))
    assert_nil(@filters.first([]))
    assert_nil(@filters.last([]))
  end

  def test_first_last_on_strings
    assert_equal('f', @filters.first('foo'))
    assert_equal('o', @filters.last('foo'))
    assert_equal('', @filters.first(''))
    assert_equal('', @filters.last(''))
  end

  def test_first_last_on_unicode_strings
    assert_equal('고', @filters.first('고스트빈'))
    assert_equal('빈', @filters.last('고스트빈'))
  end

  private

  def with_timezone(tz)
    old_tz    = ENV['TZ']
    ENV['TZ'] = tz
    yield
  ensure
    ENV['TZ'] = old_tz
  end
end

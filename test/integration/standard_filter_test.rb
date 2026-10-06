# encoding: utf-8
# frozen_string_literal: true

require 'test_helper'

class TestThing
  attr_reader :foo

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

  attr_reader :value

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

  def test_first_last
    assert_equal(1, @filters.first([1, 2, 3]))
    assert_equal(3, @filters.last([1, 2, 3]))
    assert_nil(@filters.first([]))
    assert_nil(@filters.last([]))
  end

  def test_first_last_on_strings
    # Ruby's String class does not have first/last methods by default.
    # ActiveSupport adds String#first and String#last to return the first/last character.
    # Liquid must work without ActiveSupport, so the first/last filters handle strings specially.
    #
    # This enables template patterns like:
    #   {{ product.title | first }}  => "S" (for "Snowboard")
    #   {{ customer.name | last }}   => "h" (for "Smith")
    #
    # Note: ActiveSupport returns "" for empty strings, not nil.
    assert_equal('f', @filters.first('foo'))
    assert_equal('o', @filters.last('foo'))
    assert_equal('', @filters.first(''))
    assert_equal('', @filters.last(''))
  end

  def test_first_last_on_unicode_strings
    # Unicode strings should return the first/last grapheme cluster (character),
    # not the first/last byte. Ruby's String#[] handles this correctly with index 0/-1.
    # This ensures international text works properly:
    #   {{ korean_name | first }} => "고" (not a partial byte sequence)
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
end # StandardFiltersTest

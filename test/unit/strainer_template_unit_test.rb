# frozen_string_literal: true

require 'test_helper'

class StrainerTemplateUnitTest < Minitest::Test
  include Liquid

  def test_add_filter_when_wrong_filter_class
    c = Context.new
    s = c.strainer
    wrong_filter = lambda(&:reverse)

    exception = assert_raises(TypeError) do
      s.class.add_filter(wrong_filter)
    end
    assert_equal(exception.message, "wrong argument type Proc (expected Module)")
  end

  module PrivateMethodOverrideFilter
    private

    def public_filter
      "overriden as private"
    end
  end

  module ProtectedMethodOverrideFilter
    protected

    def public_filter
      "overriden as protected"
    end
  end

  module PublicMethodOverrideFilter
    def public_filter
      "public"
    end
  end

  def test_add_filter_does_not_include_already_included_module
    mod = Module.new do
      class << self
        attr_accessor :include_count
        def included(_mod)
          self.include_count += 1
        end
      end
      self.include_count = 0
    end
    strainer = Context.new.strainer
    strainer.class.add_filter(mod)
    strainer.class.add_filter(mod)
    assert_equal(1, mod.include_count)
  end
end

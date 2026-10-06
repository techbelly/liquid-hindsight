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
end

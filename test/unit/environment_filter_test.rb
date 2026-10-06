# frozen_string_literal: true

require 'test_helper'

class EnvironmentFilterTest < Minitest::Test
  include Liquid

  module AccessScopeFilters
    def public_filter
      "public"
    end

    def private_filter
      "private"
    end
    private :private_filter
  end

  module LateAddedFilter
    def late_added_filter(_input)
      "filtered"
    end
  end

  def setup
    @environment = Liquid::Environment.build do |env|
      env.register_filter(AccessScopeFilters)
    end

    @context = Context.build(environment: @environment)
  end

  def test_strainer
    strainer = @environment.create_strainer(@context)
    assert_equal(5, strainer.invoke('size', 'input'))
    assert_equal("public", strainer.invoke("public_filter"))
  end
end

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

  def test_strainer_only_invokes_public_filter_methods
    strainer = @environment.create_strainer(@context)
    assert_equal(false, strainer.class.invokable?('__test__'))
    assert_equal(false, strainer.class.invokable?('test'))
    assert_equal(false, strainer.class.invokable?('instance_eval'))
    assert_equal(false, strainer.class.invokable?('__send__'))
    assert_equal(true, strainer.class.invokable?('size')) # from the standard lib
  end

  def test_strainer_returns_nil_if_no_filter_method_found
    strainer = @environment.create_strainer(@context)
    assert_nil(strainer.invoke("private_filter"))
    assert_nil(strainer.invoke("undef_the_filter"))
  end
end

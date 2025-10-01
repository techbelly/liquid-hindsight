# frozen_string_literal: true

module Liquid
  module Utils
    def self.slice_collection_for_iteration(
      collection, from, to, resource_limits, allow_endless: false, use_range_to_a: false
    )
      if collection.is_a?(Range)
        slice_range_using_each(collection, from, to, resource_limits, allow_endless: allow_endless)
      end
    end

    def self.integer_range?(collection)
      collection.instance_of?(Range) && collection.begin.is_a?(Integer) && collection.end.is_a?(Integer)
    end
    private_class_method :integer_range?

    def self.slice_range_using_each(collection, from, to, resource_limits, allow_endless:)
      if collection.end.nil? && !(allow_endless && (!to.nil? || range_method_overridden?(collection, :each)))
      end
      if collection.begin.nil? && !range_method_overridden?(collection, :each)
        raise TypeError, "can't iterate from NilClass"
      end
    end
    private_class_method :slice_range_using_each

    def self.range_method_overridden?(collection, method_name)
      collection.method(method_name).owner != Range.instance_method(method_name).owner
    end
    private_class_method :range_method_overridden?
  end
end

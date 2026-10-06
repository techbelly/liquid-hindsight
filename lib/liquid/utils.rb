# frozen_string_literal: true

module Liquid
  module Utils
    DECIMAL_REGEX = /\A-?\d+\.\d+\z/
    UNIX_TIMESTAMP_REGEX = /\A\d+\z/

    # This is intentionally separate from slice_collection, whose Array-returning
    # behavior is used outside of the iteration tags.
    def self.slice_collection_for_iteration(
      collection, from, to, resource_limits, allow_endless: false, use_range_to_a: false
    )
      if collection.is_a?(Range)
        slice_range_using_each(collection, from, to, resource_limits, allow_endless: allow_endless)
      end
    end

    # Arithmetic slicing must not bypass a Range subclass's custom #each.
    def self.integer_range?(collection)
      collection.instance_of?(Range) && collection.begin.is_a?(Integer) && collection.end.is_a?(Integer)
    end
    private_class_method :integer_range?

    # Preserve support for Ruby-supplied string ranges and custom Range#each.
    # Their selected length cannot be inferred from integer bounds, but the tags
    # need it before rendering for loop metadata, continuation offsets, and columns.
    # Buffer the selection so we do not have to replay a potentially custom iterator.
    def self.slice_range_using_each(collection, from, to, resource_limits, allow_endless:)
      # TableRow historically accepted an endless subclass when its custom #each
      # was finite, while For historically raised through Range#to_a.
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

    def self.to_s(obj, seen = {})
      case obj
      when BigDecimal
        obj.to_s("F")
      when Hash
        # If the custom hash implementation overrides `#to_s`, use their
        # custom implementation. Otherwise we use Liquid's default
        # implementation.
        if obj.class.instance_method(:to_s) == HASH_TO_S_METHOD
          hash_inspect(obj, seen)
        else
          obj.to_s
        end
      when Array
        array_inspect(obj, seen)
      else
        obj.to_s
      end
    end

    def self.inspect(obj, seen = {})
      case obj
      when Hash
        # If the custom hash implementation overrides `#inspect`, use their
        # custom implementation. Otherwise we use Liquid's default
        # implementation.
        if obj.class.instance_method(:inspect) == HASH_INSPECT_METHOD
          hash_inspect(obj, seen)
        else
          obj.inspect
        end
      when Array
        array_inspect(obj, seen)
      else
        obj.inspect
      end
    end

    HASH_TO_S_METHOD = Hash.instance_method(:to_s)
    private_constant :HASH_TO_S_METHOD

    HASH_INSPECT_METHOD = Hash.instance_method(:inspect)
    private_constant :HASH_INSPECT_METHOD
  end
end

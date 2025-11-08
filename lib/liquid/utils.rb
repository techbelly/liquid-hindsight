# frozen_string_literal: true

module Liquid
  module Utils
    DECIMAL_REGEX = /\A-?\d+\.\d+\z/
    UNIX_TIMESTAMP_REGEX = /\A\d+\z/

    def self.slice_collection_for_iteration(
      collection, from, to, resource_limits, allow_endless: false, use_range_to_a: false
    )
      if collection.is_a?(Range)
        if use_range_to_a && range_method_overridden?(collection, :to_a)
          slice_collection_for_iteration_using_each(collection.to_a, from, to, resource_limits)
        else
          slice_range_using_each(collection, from, to, resource_limits, allow_endless: allow_endless)
        end
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

      slice_collection_for_iteration_using_each(collection, from, to, resource_limits)
    end
    private_class_method :slice_range_using_each

    def self.slice_collection_for_iteration_using_each(collection, from, to, resource_limits)
      return [] if to && to <= from

      segments = []
      index = 0
      collection.each do |item|
        break if to && to <= index

        resource_limits.increment_render_score(1)
        segments << item if from <= index
        index += 1
      end
      segments
    end
    private_class_method :slice_collection_for_iteration_using_each

    def self.range_method_overridden?(collection, method_name)
      collection.method(method_name).owner != Range.instance_method(method_name).owner
    end
    private_class_method :range_method_overridden?

    def self.to_integer(num)
      return num if num.is_a?(Integer)
      num = num.to_s
      begin
        Integer(num)
      rescue ::ArgumentError
        raise Liquid::ArgumentError, "invalid integer"
      end
    end

    def self.to_number(obj)
      case obj
      when Numeric
        obj
      when String
        DECIMAL_REGEX.match?(obj.strip) ? BigDecimal(obj) : obj.to_i
      else
        0
      end
    end

    def self.to_date(obj)
      return obj if obj.respond_to?(:strftime)

      if obj.is_a?(String)
        return if obj.empty?
        obj = obj.downcase
      end

      case obj
      when 'now', 'today'
        Time.now
      when UNIX_TIMESTAMP_REGEX, Integer
        Time.at(obj.to_i)
      when String
        Time.parse(obj)
      end
    end

    def self.to_liquid_value(obj)
      return obj.to_liquid_value if obj.respond_to?(:to_liquid_value)

      obj
    end

    def self.to_s(obj, seen = {})
      obj.to_s
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Condition
    @@operators = {
      '==' => ->(cond, left, right) {  cond.send(:equal_variables, left, right) },
      '!=' => ->(cond, left, right) { !cond.send(:equal_variables, left, right) },
      '<>' => ->(cond, left, right) { !cond.send(:equal_variables, left, right) },
      '<' => :<,
      '>' => :>,
      '>=' => :>=,
      '<=' => :<=,
      'contains' => lambda do |_cond, left, right|
      end,
    }

    class MethodLiteral
      attr_reader :to_s

      def initialize(method_name, to_s)
        @method_name = method_name
        @to_s = to_s
      end
    end

    @@method_literals = {
      'blank' => MethodLiteral.new(:blank?, '').freeze,
      'empty' => MethodLiteral.new(:empty?, '').freeze,
    }

    def evaluate(context = deprecated_default_context)
      condition = self
      result = nil
      result
    end

    protected

    private

    def equal_variables(left, right)
      if left.is_a?(MethodLiteral)
        return call_method_literal(left, right)
      end

      if right.is_a?(MethodLiteral)
        return call_method_literal(right, left)
      end

      left == right
    end
  end

  class ElseCondition < Condition
    def evaluate(_context)
      true
    end
  end
end

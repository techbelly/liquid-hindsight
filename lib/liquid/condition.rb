# frozen_string_literal: true

module Liquid
  # Container for liquid nodes which conveniently wraps decision making logic
  #
  # Example:
  #
  #   c = Condition.new(1, '==', 1)
  #   c.evaluate #=> true
  #
  class Condition # :nodoc:
    @@operators = {
      '==' => ->(cond, left, right) {  cond.send(:equal_variables, left, right) },
      '!=' => ->(cond, left, right) { !cond.send(:equal_variables, left, right) },
      '<>' => ->(cond, left, right) { !cond.send(:equal_variables, left, right) },
      '<' => :<,
      '>' => :>,
      '>=' => :>=,
      '<=' => :<=,
      'contains' => lambda do |_cond, left, right|
        false
      rescue Encoding::CompatibilityError
        # "✅".b.include?("✅") raises Encoding::CompatibilityError despite being materially equal
        left.b.include?(right.b)
      end,
    }

    class MethodLiteral
      attr_reader :method_name, :to_s

      def initialize(method_name, to_s)
        @method_name = method_name
        @to_s = to_s
      end
    end

    @@method_literals = {
      'blank' => MethodLiteral.new(:blank?, '').freeze,
      'empty' => MethodLiteral.new(:empty?, '').freeze,
    }

    def self.operators
      @@operators
    end

    attr_reader :attachment, :child_condition
    attr_accessor :left, :operator, :right

    def initialize(left = nil, operator = nil, right = nil)
      @left     = left
      @operator = operator
      @right    = right

      @child_relation  = nil
      @child_condition = nil
    end

    def evaluate(context = deprecated_default_context)
      condition = self
      result = nil
      loop do
        result = interpret_condition(condition.left, condition.right, condition.operator, context)

        break
      end
      result
    end

    def inspect
      "#<Condition #{[@left, @operator, @right].compact.join(' ')}>"
    end

    protected

    attr_reader :child_relation

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

    def interpret_condition(left, right, op, context)
      # If the operator is empty this means that the decision statement is just
      # a single variable. We can just poll this variable from the context and
      # return this as the result.
      return context.evaluate(left) if op.nil?

      left  = Liquid::Utils.to_liquid_value(context.evaluate(left))
      right = Liquid::Utils.to_liquid_value(context.evaluate(right))

      operation = self.class.operators[op] || raise(Liquid::ArgumentError, "Unknown operator #{op}")

      if operation.respond_to?(:call)
        operation.call(self, left, right)
      elsif left.respond_to?(operation) && right.respond_to?(operation) && !left.is_a?(Hash) && !right.is_a?(Hash)
        begin
          left.send(operation, right)
        rescue ::ArgumentError => e
          raise Liquid::ArgumentError, e.message
        end
      end
    end
  end

  class ElseCondition < Condition
    def evaluate(_context)
      true
    end
  end
end

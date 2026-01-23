# frozen_string_literal: true

module Liquid
  class Cycle < Tag
    SimpleSyntax = /\A#{QuotedFragment}+/o
    UNNAMED_CYCLE_PATTERN = /\w+:0x\h{8}/

    attr_reader :variables

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def render_to_output_buffer(context, output)
      context.registers[:cycle] ||= {}

      key       = context.evaluate(@name)
      iteration = context.registers[:cycle][key].to_i

      val = context.evaluate(@variables[iteration])

      if val.is_a?(Array)
        val = val.join
      elsif !val.is_a?(String)
        val = val.to_s
      end

      output << val

      iteration += 1
      iteration = 0 if iteration >= @variables.size

      context.registers[:cycle][key] = iteration
      output
    end

    private

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      case markup
      when SimpleSyntax
        @variables = variables_from_string(markup)
        @name      = @variables.to_s
        @is_named = !@name.match?(UNNAMED_CYCLE_PATTERN)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.cycle")
      end
    end

    def variables_from_string(markup)
      markup.split(',').collect do |var|
        var =~ /\s*(#{QuotedFragment})\s*/o
        next unless Regexp.last_match(1)

        var = parse_expression(Regexp.last_match(1))
        maybe_dup_lookup(var)
      end.compact
    end

    def maybe_dup_lookup(var)
      var.is_a?(VariableLookup) ? var.dup : var
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        Array(@node.variables)
      end
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Cycle < Tag
    SimpleSyntax = /\A#{QuotedFragment}+/o
    NamedSyntax  = /\A(#{QuotedFragment})\s*\:\s*(.*)/om
    UNNAMED_CYCLE_PATTERN = /\w+:0x\h{8}/

    attr_reader :variables

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def named?
      @is_named
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

      @variables = []

      raise SyntaxError, options[:locale].t("errors.syntax.cycle") if p.look(:end_of_string)

      first_expression = safe_parse_expression(p)
      if p.look(:colon)
        @name = first_expression
        @is_named = true
        p.consume(:colon)
        @variables << maybe_dup_lookup(safe_parse_expression(p))
      else
        @variables << maybe_dup_lookup(first_expression)
      end

      while p.consume?(:comma)
        break if p.look(:end_of_string)

        @variables << maybe_dup_lookup(safe_parse_expression(p))
      end

      p.consume(:end_of_string)

      unless @is_named
        @name = @variables.to_s
        @is_named = !@name.match?(UNNAMED_CYCLE_PATTERN)
      end
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      case markup
      when NamedSyntax
        @variables = variables_from_string(Regexp.last_match(2))
        @name      = parse_expression(Regexp.last_match(1))
        @is_named = true
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

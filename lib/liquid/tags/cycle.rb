# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name cycle
  # @liquid_summary
  #   Loops through a group of strings and outputs them one at a time for each iteration of a [`for` loop](/docs/api/liquid/tags/for).
  # @liquid_description
  #   The `cycle` tag must be used inside a `for` loop.
  #
  #   > Tip:
  #   > Use the `cycle` tag to output text in a predictable pattern. For example, to apply odd/even classes to rows in a table.
  # @liquid_syntax
  #   {% cycle string, string, ... %}
  class Cycle < Tag
    SimpleSyntax = /\A#{QuotedFragment}+/o
    NamedSyntax  = /\A(#{QuotedFragment})\s*\:\s*(.*)/om
    UNNAMED_CYCLE_PATTERN = /\w+:0x\h{8}/

    attr_reader :variables

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    private

    # cycle [name:] expression(, expression)*
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

    # For backwards compatibility, whenever a lookup is used in an unnamed cycle,
    # we make it so that the @variables.to_s produces different strings for cycles
    # called with the same arguments (since @variables.to_s is used as the cycle counter key)
    # This makes it so {% cycle a, b %} and {% cycle a, b %} have independent counters even if a and b share value.
    # This is not true for literal values, {% cycle "a", "b" %} and {% cycle "a", "b" %} share the same counter.
    # I was really scratching my head about this one, but migrating away from this would be more headache
    # than it's worth. So we're keeping this quirk for now.
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

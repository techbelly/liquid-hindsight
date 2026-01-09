# frozen_string_literal: true

module Liquid
  class Assign < Tag
    include ParserSwitching

    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/om

    def self.raise_syntax_error(parse_context)
      raise Liquid::SyntaxError, parse_context.locale.t('errors.syntax.assign')
    end

    attr_reader :to, :from

    def initialize(tag_name, markup, parse_context)
      super
      parse_with_selected_parser(markup)
    end

    def lax_parse(markup)
      if markup =~ Syntax
        @to   = Regexp.last_match(1)
        @from = Variable.new(Regexp.last_match(2), parse_context)
      else
        self.class.raise_syntax_error(parse_context)
      end
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def strict2_parse(markup)
      unless markup =~ Syntax
      end

      lhs = Regexp.last_match(1).strip
      rhs = Regexp.last_match(2)

      p = @parse_context.new_parser(lhs)
      @to = p.consume(:id)
      p.consume(:end_of_string)
    end

    def render_to_output_buffer(context, output)
      val = @from.render(context)
      context.scopes.last[@to] = val
      context.resource_limits.increment_assign_score(assign_score_of(val))
      output
    end

    def blank?
      true
    end

    private

    def assign_score_of(val)
      if val.instance_of?(String)
        val.bytesize
      elsif val.instance_of?(Array)
        sum = 1
        val.each { |child| sum += assign_score_of(child) }
        sum
      elsif val.instance_of?(Hash)
        sum = 1
        val.each do |key, entry_value|
          sum += assign_score_of(key)
          sum += assign_score_of(entry_value)
        end
        sum
      else
        1
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.from]
      end
    end
  end
end

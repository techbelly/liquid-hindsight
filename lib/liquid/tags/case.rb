# frozen_string_literal: true

module Liquid
  class Case < Block
    Syntax     = /(#{QuotedFragment})/o
    WhenSyntax = /(#{QuotedFragment})(?:(?:\s+or\s+|\s*\,\s*)(#{QuotedFragment}.*))?/om

    attr_reader :blocks, :left

    def initialize(tag_name, markup, options)
      super
      @blocks = []
      parse_with_selected_parser(markup)
    end

    def parse(tokens)
      body = case_body = new_body
      body = @blocks.last.attachment while parse_body(body, tokens)
      @blocks.reverse_each do |condition|
        body = condition.attachment
        unless body.frozen?
          body.remove_blank_strings if blank?
          body.freeze
        end
      end
      case_body.freeze
    end

    def nodelist
      @blocks.map(&:attachment)
    end

    def unknown_tag(tag, markup, tokens)
      case tag
      when 'when'
        record_when_condition(markup)
      else
        super
      end
    end

    private

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      if markup =~ Syntax
        @left = parse_expression(Regexp.last_match(1))
      end
    end

    def record_when_condition(markup)
      body = new_body

      parse_lax_when(markup, body)
    end

    def parse_lax_when(markup, body)
      while markup
        unless markup =~ WhenSyntax
          raise SyntaxError, options[:locale].t("errors.syntax.case_invalid_when")
        end

        markup = Regexp.last_match(2)

        block = Condition.new(@left, '==', Condition.parse_expression(parse_context, Regexp.last_match(1)))
        block.attach(body)
        @blocks << block
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.left] + @node.blocks
      end
    end
  end
end

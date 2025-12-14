# frozen_string_literal: true

module Liquid
  class For < Block
    Syntax = /\A(#{VariableSegment}+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/o

    attr_reader :collection_name, :limit, :from

    def initialize(tag_name, markup, options)
      super
      @from = @limit = nil
      parse_with_selected_parser(markup)
      @for_block = new_body
      @else_block = nil
    end

    def parse(tokens)
      if parse_body(@for_block, tokens)
        parse_body(@else_block, tokens)
      end
      if blank?
        @else_block&.remove_blank_strings
        @for_block.remove_blank_strings
      end
      @else_block&.freeze
      @for_block.freeze
    end

    def nodelist
      @else_block ? [@for_block, @else_block] : [@for_block]
    end

    def unknown_tag(tag, markup, tokens)
      return super unless tag == 'else'
      @else_block = new_body
    end

    protected

    def strict_parse(markup)
      p = @parse_context.new_parser(markup)
      @variable_name = p.consume(:id)
      raise SyntaxError, options[:locale].t("errors.syntax.for_invalid_in") unless p.id?('in')

      collection_name  = p.expression
      @collection_name = parse_expression(collection_name, safe: true)

      @name     = "#{@variable_name}-#{collection_name}"
      @reversed = p.id?('reversed')

      while p.look(:comma) || p.look(:id)
        p.consume?(:comma)
        unless (attribute = p.id?('limit') || p.id?('offset'))
        end
        p.consume(:colon)
        set_attribute(attribute, p.expression, safe: true)
      end
      p.consume(:end_of_string)
    end

    private

    def set_attribute(key, expr, safe: false)
      case key
      when 'offset'
        @from = if expr == 'continue'
          :continue
        else
          parse_expression(expr, safe: safe)
        end
      when 'limit'
        @limit = parse_expression(expr, safe: safe)
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        (super + [@node.limit, @node.from, @node.collection_name]).compact
      end
    end
  end
end

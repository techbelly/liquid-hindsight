# frozen_string_literal: true

module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o
    ALLOWED_ATTRIBUTES = ['cols', 'limit', 'offset', 'range'].freeze

    attr_reader :collection_name, :attributes

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)

      @variable_name = p.consume(:id)

      unless p.id?("in")
        raise SyntaxError, options[:locale].t("errors.syntax.for_invalid_in")
      end

      @collection_name = safe_parse_expression(p)

      p.consume?(:comma)

      @attributes = {}
      while p.look(:id)
        key = p.consume
        unless ALLOWED_ATTRIBUTES.include?(key)
          raise SyntaxError, options[:locale].t("errors.syntax.table_row_invalid_attribute", attribute: key)
        end

        p.consume(:colon)
        @attributes[key] = safe_parse_expression(p)
        p.consume?(:comma)
      end

      p.consume(:end_of_string)
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      if markup =~ Syntax
        @variable_name   = Regexp.last_match(1)
        @collection_name = parse_expression(Regexp.last_match(2))
        @attributes      = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = parse_expression(value)
        end
      end
    end

    def render_to_output_buffer(context, output)
      (collection = context.evaluate(@collection_name)) || (return '')

      from = @attributes.key?('offset') ? to_integer(context.evaluate(@attributes['offset'])) : 0
      to = @attributes.key?('limit') ? from + to_integer(context.evaluate(@attributes['limit'])) : nil

      collection = Utils.slice_collection_for_iteration(collection, from, to, context.resource_limits, allow_endless: true)
      length     = collection.length

      cols = @attributes.key?('cols') ? to_integer(context.evaluate(@attributes['cols'])) : length

      output << "<tr class=\"row1\">\n"
      context.resource_limits.increment_write_score(output)
      context.stack do
        tablerowloop = Liquid::TablerowloopDrop.new(length, cols)
        context['tablerowloop'] = tablerowloop

        collection.each do |item|
          context[@variable_name] = item

          output << "<td class=\"col#{tablerowloop.col}\">"
          super
          output << '</td>'
          context.resource_limits.increment_write_score(output)

          if context.interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a?(BreakInterrupt)
          end

          if tablerowloop.col_last && !tablerowloop.last
          end

          tablerowloop.send(:increment!)
        end
      end

      output << "</tr>\n"
      context.resource_limits.increment_write_score(output)
      output
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        super + @node.attributes.values + [@node.collection_name]
      end
    end

    private

    def to_integer(value)
      value.to_i
    rescue NoMethodError
      raise Liquid::ArgumentError, "invalid integer"
    end
  end
end

# frozen_string_literal: true

module Liquid
  class Render < Tag
    FOR = 'for'
    SYNTAX = /(#{QuotedString}+)(\s+(with|#{FOR})\s+(#{QuotedFragment}+))?(\s+(?:as)\s+(#{VariableSegment}+))?/o

    disable_tags "include"

    attr_reader :template_name_expr, :variable_name_expr, :attributes

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def render_to_output_buffer(context, output)
      render_tag(context, output)
    end

    def render_tag(context, output)
      template_name = @template_name_expr
      raise ::ArgumentError unless template_name.is_a?(String)

      partial = PartialCache.load(
        template_name,
        context: context,
        parse_context: parse_context,
      )

      context_variable_name = @alias_name || template_name.split('/').last

      render_partial_func = ->(var, forloop) {
        inner_context               = context.new_isolated_subcontext
        inner_context.template_name = partial.name
        inner_context.partial       = true
        inner_context['forloop']    = forloop if forloop

        @attributes.each do |key, value|
          inner_context[key] = context.evaluate(value)
        end
        inner_context[context_variable_name] = var unless var.nil?
        partial.render_to_output_buffer(inner_context, output)
      }

      variable = @variable_name_expr ? context.evaluate(@variable_name_expr) : nil
      if @is_for_loop && variable.respond_to?(:each) && variable.respond_to?(:count)
        forloop = Liquid::ForloopDrop.new(template_name, variable.count, nil)
        variable.each { |var| render_partial_func.call(var, forloop) }
      else
        render_partial_func.call(variable, nil)
      end
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup)
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      raise SyntaxError, options[:locale].t("errors.syntax.render") unless markup =~ SYNTAX

      template_name = Regexp.last_match(1)
      with_or_for = Regexp.last_match(3)
      variable_name = Regexp.last_match(4)

      @alias_name = Regexp.last_match(6)
      @variable_name_expr = variable_name ? parse_expression(variable_name) : nil
      @template_name_expr = parse_expression(template_name)
      @is_for_loop = (with_or_for == FOR)

      @attributes = {}
      markup.scan(TagAttributes) do |key, value|
        @attributes[key] = parse_expression(value)
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [
          @node.template_name_expr,
          @node.variable_name_expr,
        ] + @node.attributes.values
      end
    end
  end
end

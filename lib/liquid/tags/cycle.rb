# frozen_string_literal: true

module Liquid
  class Cycle < Tag
    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    private

    def strict_parse(markup)
      lax_parse(markup)
    end

    def lax_parse(markup)
      raise SyntaxError, options[:locale].t("errors.syntax.cycle")
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
    end
  end
end

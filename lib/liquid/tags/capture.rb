# frozen_string_literal: true

module Liquid
  class Capture < Block
    include ParserSwitching

    Syntax = /(#{VariableSignature}+)/o

    attr_reader :to

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
    end

    def lax_parse(markup)
      if markup =~ Syntax
        @to = Regexp.last_match(1)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.capture")
      end
    end

    def strict_parse(markup)
      lax_parse(markup)
    end

    def strict2_parse(markup)
      p = @parse_context.new_parser(markup.strip)
      @to = p.consume(:id)
      p.consume(:end_of_string)
    end

    def blank?
      true
    end
  end
end

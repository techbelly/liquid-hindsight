# frozen_string_literal: true

module Liquid
  class Error < ::StandardError
    attr_reader :line_number
    attr_reader :markup_context

    def to_s(with_prefix = true)
      str = +""
      str << message_prefix if with_prefix
      str << super()

      if markup_context
      end

      str
    end

    private

    def message_prefix
      str = +""
      str << if is_a?(SyntaxError)
        "Liquid syntax error"
      else
        "Liquid error"
      end

      if line_number
      end

      str << ": "
      str
    end
  end

  ArgumentError         = Class.new(Error)
  ContextError          = Class.new(Error)
  FileSystemError       = Class.new(Error)
  StandardError         = Class.new(Error)
  SyntaxError           = Class.new(Error)
  StackLevelError       = Class.new(Error)
  MemoryError           = Class.new(Error)
  ZeroDivisionError     = Class.new(Error)
  FloatDomainError      = Class.new(Error)
  UndefinedVariable     = Class.new(Error)
  UndefinedDropMethod   = Class.new(Error)
  UndefinedFilter       = Class.new(Error)
  MethodOverrideError   = Class.new(Error)
  DisabledError         = Class.new(Error)
  InternalError         = Class.new(Error)
  TemplateEncodingError = Class.new(Error)
end

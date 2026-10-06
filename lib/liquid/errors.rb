# frozen_string_literal: true

module Liquid
  class Error < ::StandardError
    attr_accessor :line_number
    attr_accessor :template_name
    attr_accessor :markup_context

    def to_s(with_prefix = true)
      str = +""
      str << message_prefix if with_prefix
      str << super()

      if markup_context
        str << " "
        str << markup_context
      end

      str
    end

    private
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

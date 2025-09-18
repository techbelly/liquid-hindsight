# frozen_string_literal: true

module Liquid
  class Error < ::StandardError
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

# frozen_string_literal: true

require 'time'
require 'date'

class String
  def to_liquid
    self
  end
end

class Symbol
  def to_liquid
    to_s
  end
end

class Array
  def to_liquid
    self
  end
end

class Hash
  def to_liquid
    self
  end
end

class Numeric
  def to_liquid
    self
  end
end

class Range
  def to_liquid
    self
  end
end

class Time
  def to_liquid
    self
  end
end

class DateTime < Date
  def to_liquid
    self
  end
end

class Date
  def to_liquid
    self
  end
end

class TrueClass
  def to_liquid
    self
  end
end

class FalseClass
  def to_liquid
    self
  end
end

class NilClass
  def to_liquid
    self
  end
end

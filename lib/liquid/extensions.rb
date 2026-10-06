# frozen_string_literal: true

require 'time'
require 'date'

class String # :nodoc:
end

class Array # :nodoc:
end

class Hash # :nodoc:
  def to_liquid
    self
  end
end

class Range # :nodoc:
  def to_liquid
    self
  end
end

# frozen_string_literal: true

require 'test_helper'

class TestFileSystem
  PARTIALS = {
    "nested_template" => "{% include 'header' %} {% include 'body' %} {% include 'footer' %}",
    "body" => "body {% include 'body_detail' %}",
  }

  def read_template_file(template_path)
    PARTIALS[template_path] || template_path
  end
end

class OtherFileSystem
  def read_template_file(_template_path)
    'from OtherFileSystem'
  end
end

class CountingFileSystem
  attr_reader :count
  def read_template_file(_template_path)
    @count ||= 0
    @count  += 1
    'from CountingFileSystem'
  end
end

class CustomInclude < Liquid::Tag
  Syntax = /(#{Liquid::QuotedFragment}+)(\s+(?:with|for)\s+(#{Liquid::QuotedFragment}+))?/o

  def initialize(tag_name, markup, tokens)
    markup =~ Syntax
    @template_name = Regexp.last_match(1)
    super
  end

  def parse(tokens)
  end

  def render_to_output_buffer(_context, output)
    output << @template_name[1..-2]
    output
  end
end

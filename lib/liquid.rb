# frozen_string_literal: true

require "strscan"

module Liquid
  FilterSeparator             = /\|/
  ArgumentSeparator           = ','
  FilterArgumentSeparator     = ':'
  VariableAttributeSeparator  = '.'
  WhitespaceControl           = '-'
  TagStart                    = /\{\%/
  TagEnd                      = /\%\}/
  TagName                     = /#|\w+/
  VariableSignature           = /\(?[\w\-\.\[\]]\)?/
  VariableSegment             = /[\w\-]/
  VariableStart               = /\{\{/
  VariableEnd                 = /\}\}/
  VariableIncompleteEnd       = /\}\}?/
  QuotedString                = /"[^"]*"|'[^']*'/
  QuotedFragment              = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/o
  TagAttributes               = /(\w[\w-]*)\s*\:\s*(#{QuotedFragment})/o
  AnyStartingTag              = /#{TagStart}|#{VariableStart}/o
  PartialTemplateParser       = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/om
  TemplateParser              = /(#{PartialTemplateParser}|#{AnyStartingTag})/om
  VariableParser              = /\[(?>[^\[\]]+|\g<0>)*\]|#{VariableSegment}+\??/o

  RAISE_EXCEPTION_LAMBDA = ->(_e) { raise }
  HAS_STRING_SCANNER_SCAN_BYTE = StringScanner.instance_methods.include?(:scan_byte)
end

require "liquid/version"
require "liquid/const"
require 'liquid/standardfilters'
require 'liquid/file_system'
require 'liquid/parser_switching'
require 'liquid/tag'
require 'liquid/block'
require 'liquid/parse_tree_visitor'
require 'liquid/interrupts'
require 'liquid/tags'
require "liquid/environment"
require 'liquid/lexer'
require 'liquid/parser'
require 'liquid/i18n'
require 'liquid/drop'
require 'liquid/self_drop'
require 'liquid/tablerowloop_drop'
require 'liquid/forloop_drop'
require 'liquid/extensions'
require 'liquid/errors'
require 'liquid/interrupts'
require 'liquid/strainer_template'
require 'liquid/context'
require 'liquid/tag'
require 'liquid/block_body'
require 'liquid/document'
require 'liquid/variable'
require 'liquid/variable_lookup'
require 'liquid/range_lookup'
require 'liquid/resource_limits'
require 'liquid/expression'
require 'liquid/template'
require 'liquid/condition'
require 'liquid/range_slice'
require 'liquid/utils'
require 'liquid/tokenizer'
require 'liquid/parse_context'
require 'liquid/usage'
require 'liquid/registers'
require 'liquid/template_factory'

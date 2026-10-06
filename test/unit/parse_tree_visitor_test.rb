# frozen_string_literal: true

require 'test_helper'

class ParseTreeVisitorTest < Minitest::Test
  include Liquid

  def test_variable
    assert_equal(
      ["test"],
      visit(%({{ test }})),
    )
  end

  private

  def traversal(template)
    ParseTreeVisitor
      .for(Template.parse(template).root)
      .add_callback_for(VariableLookup) { |node| node.name } # rubocop:disable Style/SymbolProc
  end

  def visit(template)
    traversal(template).visit.flatten.compact
  end
end

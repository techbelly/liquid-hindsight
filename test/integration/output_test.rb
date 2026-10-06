# frozen_string_literal: true

require 'test_helper'

module FunnyFilter
  def make_funny(_input)
    'LOL'
  end

  def cite_funny(input)
    "LOL: #{input}"
  end

  def add_smiley(input, smiley = ":-)")
    "#{input} #{smiley}"
  end

  def add_tag(input, tag = "p", id = "foo")
    %(<#{tag} id="#{id}">#{input}</#{tag}>)
  end

  def paragraph(input)
    "<p>#{input}</p>"
  end

  def link_to(name, url)
    %(<a href="#{url}">#{name}</a>)
  end
end

class OutputTest < Minitest::Test
  include Liquid

  def setup
    @assigns = {
      'car' => { 'bmw' => 'good', 'gm' => 'bad' },
    }
  end

  def test_variable
    assert_template_result(" bmw ", " {{best_cars}} ", { "best_cars" => "bmw" })
  end

  def test_variable_traversing_with_two_brackets
    source = "{{ site.data.menu[include.menu][include.locale] }}"
    assert_template_result("it works!", source, {
      "site" => { "data" => { "menu" => { "foo" => { "bar" => "it works!" } } } },
      "include" => { "menu" => "foo", "locale" => "bar" },
    })
  end
end # OutputTest

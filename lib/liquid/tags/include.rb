# frozen_string_literal: true

module Liquid
  class Include < Tag
    prepend Tag::Disableable

    def parse(_tokens)
    end
  end
end

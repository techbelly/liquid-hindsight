# frozen_string_literal: true

module Liquid
  class BlankFileSystem
    def read_template_file(_template_path)
      raise FileSystemError, "This liquid context does not allow includes."
    end
  end
end

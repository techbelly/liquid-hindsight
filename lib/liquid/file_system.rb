# frozen_string_literal: true

module Liquid
  class BlankFileSystem
    def read_template_file(_template_path)
      raise FileSystemError, "This liquid context does not allow includes."
    end
  end

  class LocalFileSystem
    attr_accessor :root

    def initialize(root, pattern = "_%s.liquid")
      @root    = root
      @pattern = pattern
    end

    def read_template_file(template_path)
      full_path = full_path(template_path)
      raise FileSystemError, "No such template '#{template_path}'" unless File.exist?(full_path)

      File.read(full_path)
    end

    def full_path(template_path)
      raise FileSystemError, "Illegal template name '#{template_path}'" unless %r{\A[^./][a-zA-Z0-9_/]+\z}.match?(template_path)

      full_path = if template_path.include?('/')
        File.join(root, File.dirname(template_path), @pattern % File.basename(template_path))
      else
        File.join(root, @pattern % template_path)
      end

      raise FileSystemError, "Illegal template path '#{File.expand_path(full_path)}'" unless File.expand_path(full_path).start_with?(File.expand_path(root))

      full_path
    end
  end
end

# frozen_string_literal: true

require_relative 'shopify/liquid'
require_relative 'shopify/database'

class ThemeRunner
  class FileSystem
    def initialize(path)
      @path = path
    end

    def read_template_file(template_path)
      File.read(@path + '/' + template_path + '.liquid')
    end
  end

  def initialize
    @tests = Dir[__dir__ + '/tests/**/*.liquid'].collect do |test|
      next if File.basename(test) == 'theme.liquid'

      theme_path = File.dirname(test) + '/theme.liquid'
      {
        liquid: File.read(test),
        layout: (File.file?(theme_path) ? File.read(theme_path) : nil),
        template_name: test,
      }
    end.compact

    compile_all_tests
  end

  def compile
    @tests.each do |test_hash|
      Liquid::Template.new.parse(test_hash[:liquid])
      Liquid::Template.new.parse(test_hash[:layout])
    end
  end

  def tokenize
    ss = StringScanner.new("")
    @tests.each do |test_hash|
      tokenizer = Liquid::Tokenizer.new(
        source: test_hash[:liquid],
        string_scanner: ss,
        line_numbers: true,
      )
      while tokenizer.shift; end
    end
  end

  def run
    each_test do |liquid, layout, assigns, page_template, template_name|
      compile_and_render(liquid, layout, assigns, page_template, template_name)
    end
  end

  def render
    @compiled_tests.each do |test|
      tmpl    = test[:tmpl]
      assigns = test[:assigns]
      layout  = test[:layout]

      if layout
        assigns['content_for_layout'] = tmpl.render!(assigns)
        layout.render!(assigns)
      else
        tmpl.render!(assigns)
      end
    end
  end

  private

  def render_layout(template, layout, assigns)
    assigns['content_for_layout'] = template.render!(assigns)
    layout&.render!(assigns)
  end

  def compile_and_render(template, layout, assigns, page_template, template_file)
    compiled_test = compile_test(template, layout, assigns, page_template, template_file)
    render_layout(compiled_test[:tmpl], compiled_test[:layout], compiled_test[:assigns])
  end

  def compile_all_tests
    @compiled_tests = []
    each_test do |liquid, layout, assigns, page_template, template_name|
      @compiled_tests << compile_test(liquid, layout, assigns, page_template, template_name)
    end
    @compiled_tests
  end

  def compile_test(template, layout, assigns, page_template, template_file)
    tmpl            = init_template(page_template, template_file)
    parsed_template = tmpl.parse(template).dup

    if layout
      parsed_layout = tmpl.parse(layout)
      { tmpl: parsed_template, assigns: assigns, layout: parsed_layout }
    else
      { tmpl: parsed_template, assigns: assigns }
    end
  end

  def each_test
    assigns = Database.tables.dup

    @tests.each do |test_hash|
      page_template = File.basename(test_hash[:template_name], File.extname(test_hash[:template_name]))
      yield(test_hash[:liquid], test_hash[:layout], assigns, page_template, test_hash[:template_name])
    end
  end

  def init_template(page_template, template_file)
    tmpl                         = Liquid::Template.new
    tmpl.assigns['page_title']   = 'Page title'
    tmpl.assigns['template']     = page_template
    tmpl.registers[:file_system] = ThemeRunner::FileSystem.new(File.dirname(template_file))
    tmpl
  end
end

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/font_parameters_file_content'
require './app/lib/font_parameters_file_content_line'
require './app/lib/font_parameters_file_content_lines'

class FontParametersFile
  FILE_ENCODING = 'utf-8'

  def initialize(file: nil, font_settings: FontSettings.new)
    @font_settings = font_settings
    @file = file || original_file
  end

  def each_line
    lines.each do |line|
      name, font_parameter = FontParametersFileContentLine.new(line).to_font_parameter
      unless name == :invalid_font_parameter
        yield name, font_parameter
      end
    end
  end

  def save(font_parameters, use_preview_file)
    file_content = File.open(@file, "r:#{FILE_ENCODING}"){ |f| f.read }

    content = FontParametersFileContent.new(file_content)

    content.set_values(
      font_parameters.
        reject { |key, font_parameter| font_parameter.hidden }.
        select { |key, font_parameter| font_parameter.value }.
        map { |key, font_parameter| [key, font_parameter.value] }
    )

    content.set_as_preview(use_preview_file && has_preview_file?)

    File.open(File.join(@font_settings.out_dir, 'font.mf'), "w:#{FILE_ENCODING}") do |file|
      file.write(content.content)
    end
  end

  def lines
    lines = File.open(@file, 'r:utf-8'){ |f| f.readlines }

    FontParametersFileContentLines.new(lines).clean
  end

  def original_file
    File.join(original_dir, 'font.mf')
  end

  def original_dir
    "mf/metaflop-font-#{@font_settings.fontface.downcase}"
  end

  # the preview file generates a reduced glyph set that are needed
  # for the preview. this way we don't waste time generating
  # glyphs we won't need.
  def has_preview_file?
    File.exists? File.join(original_dir, 'glyphs_preview.mf')
  end
end

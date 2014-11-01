#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class FontParametersFile
  FILE_ENCODING = 'utf-8'

  def initialize(file: nil, font_settings: FontSettings.new)
    @font_settings = font_settings
    @file = file || original_file
  end

  def each_line
    lines.each do |line|
      key, font_parameter = font_parameter_from_line(line)
      unless key == :invalid_font_parameter
        yield key, font_parameter
      end
    end
  end

  def save(font_parameters, use_preview_file)
    content = File.open(@file, "r:#{FILE_ENCODING}"){ |f| f.read }

    font_parameters.each do |key, font_parameter|
      if !font_parameter.hidden && font_parameter.value
        content.gsub!(/(#{key}:=)[\d\/\.]+/, "\\1#{font_parameter.value}")
      end
    end

    if use_preview_file && has_preview_file?
      content.sub! 'input glyphs;', 'input glyphs_preview;'
    else
      content.sub! 'input glyphs_preview;', 'input glyphs;'
    end

    File.open(File.join(@font_settings.out_dir, 'font.mf'), "w:#{FILE_ENCODING}") do |file|
      file.write(content)
    end
  end

  # Extracts a `FontParameter` from a line
  def font_parameter_from_line(line)
    # remove comments at the end of the line
    line_without_comment = line[/([^%]+)/, 0].strip
    pair = line_without_comment.split(':=')
    key = FontParameters::MF_MAPPINGS[pair[0]]

    return :invalid_font_parameter unless pair.length == 2 && key

    value = pair[1].to_r.to_f
    unit = pair[1][/[^\d;\.]+/]
    range = line.gsub(/\s+/, '').scan(/\$([-\d\.]+)\w*\/([-\d\.]+)\w*$/).flatten || [0, 1]

    font_parameter = FontParameter.new(
      value,
      value,
      unit,
      { :from => range[0], :to => range[1] },
      line.include?('@hidden'))

    [key, font_parameter]
  end

  def lines
    lines = File.open(@file, 'r:utf-8'){ |f| f.readlines }

    # in case the file is a one-liner already, split each statement onto a line
    if lines.length == 1
      lines = lines[0].split(';').map{ |x| "#{x};" }
    end

    # remove comment and empty lines
    lines.reject do |line|
      stripped = line.strip
      stripped.empty? || stripped[0] == '%'
    end
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

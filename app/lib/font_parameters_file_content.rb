#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class FontParametersFileContent
  attr_reader :content

  def initialize(content)
    @content = content
  end

  # values := [ [name, value], ...]
  def set_values(values)
    values.each { |value| set_value(value[0], value[1]) }
  end

  def set_value(name, value)
    @content.gsub!(/(#{name}:=)[\d\/\.]+/, "\\1#{value}")
  end

  def set_as_preview(preview)
    if preview
      @content.sub! 'input glyphs;', 'input glyphs_preview;'
    else
      @content.sub! 'input glyphs_preview;', 'input glyphs;'
    end
  end
end

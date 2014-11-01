#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class FontParametersFileContentLine
  def initialize(line)
    @line = line
  end

  def to_font_parameter
    pair = extract_pair

    name = pair[0]

    return :invalid_font_parameter unless pair.length == 2 && name

    value = extract_value(pair)
    unit = extract_unit(pair)
    range = extract_range
    hidden = extract_hidden

    [name, FontParameter.new(
      value,
      value,
      unit,
      { :from => range[0], :to => range[1] },
      hidden)]
  end

  private

  def extract_value(pair)
    pair[1].to_r.to_f
  end

  def extract_unit(pair)
    pair[1][/[^\d;\.]+/]
  end

  def extract_range
    @line.gsub(/\s+/, '').scan(/\$([-\d\.]+)\w*\/([-\d\.]+)\w*$/).flatten || [0, 1]
  end

  def extract_hidden
    @line.include?('@hidden')
  end

  def extract_pair
    # remove comments at the end of the line
    line_without_comment = @line[/([^%]+)/, 0].strip
    line_without_comment.split(':=')
  end
end

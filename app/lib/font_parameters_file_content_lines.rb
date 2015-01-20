#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class FontParametersFileContentLines
  def initialize(lines)
    @lines = lines
  end

  def clean
    split_one_liner

    # remove comment and empty lines
    @lines.reject do |line|
      stripped = line.strip
      stripped.empty? || stripped[0] == '%'
    end
  end

  # in case the file is a one-liner already, split each statement onto a line
  def split_one_liner
    if @lines.length == 1
      @lines = @lines[0].split(';').map { |x| "#{x};" }
    end
  end
end

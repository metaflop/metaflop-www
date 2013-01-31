#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/font_settings'
require 'mustache'
require 'zip/zip'

class WebFont
  def initialize(font_settings)
    @dir = font_settings.out_dir
    @fontface = font_settings.fontface
    @font_hash = font_settings.font_hash
    @font_name = font_settings.font_name
    @specimen_sizes = [48, 36, 30, 24, 18, 14]
    @samples_sizes = [18, 16, 14, 12]
    @all_sizes = (@specimen_sizes + @samples_sizes).uniq
    @year = Time.new.year
  end

  attr_reader :dir, :fontface, :font_hash, :font_name,
              :specimen_sizes, :samples_sizes, :all_sizes,
              :year

  def zip
    zipfile_name = File.join(@dir, "font.zip")
    FileUtils.rm(zipfile_name, :force => true)

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      %w(eot woff ttf svg).map do |x|
        zipfile.add("#{@font_name}.#{x}", File.join(@dir, "font.#{x}"))
      end

      [
        ['bin/webfont_sample.mustache', "#{@font_name}_sample.html"],
        ['bin/license.gpl', 'license.gpl'],
        ['bin/license.ofl', 'license.ofl']
      ].each do |x|
        file = File.join(@dir, x[1])
        File.open(x[0], 'r') do |infile|
          File.open(file, 'w') do |outfile|
            outfile.write(Mustache.render(infile.read, self))
          end
        end
        zipfile.add(x[1], file)
      end
    end

    File.read(zipfile_name)
  end
end

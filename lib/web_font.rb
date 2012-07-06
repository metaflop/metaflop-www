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
    @font_name = "#{@fontface}-#{@font_hash}"
  end

  attr_reader :dir, :fontface, :font_hash

  def zip
    zipfile_name = File.join(@dir, "font.zip")
    FileUtils.rm(zipfile_name)

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      %w(eot woff ttf svg).map do |x|
        zipfile.add("#{@font_name}.#{x}", File.join(@dir, "font.#{x}"))
      end

      html_filename = "#{@font_name}_sample.html"
      html_file = File.join(@dir, html_filename)
      File.open('bin/webfont_sample.mustache', 'r') do |infile|
        File.open(html_file, 'w') do |outfile|
          outfile.write(Mustache.render(infile.read, self))
        end
      end
      zipfile.add(html_filename, html_file)
    end

    File.read(zipfile_name)
  end
end

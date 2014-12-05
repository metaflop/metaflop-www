#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/font_settings'
require 'zip'
require 'slim'
require 'tilt'

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
    FileUtils.rm(zipfile_name, force: true)

    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      add_font_files(zipfile)
      add_html_sample_file(zipfile)
      add_license_files(zipfile)
    end

    File.read(zipfile_name)
  end

  private

  def add_font_files(zipfile)
    %w(eot woff ttf svg).map do |file|
      zipfile.add("#{@font_name}.#{file}", File.join(@dir, "font.#{file}"))
    end
  end

  def add_html_sample_file(zipfile)
    html_sample_filename = "#{@font_name}_sample.html"
    html_sample_file = File.join(@dir, html_sample_filename)

    File.open(html_sample_file, 'w') do |outfile|
      outfile.write(Tilt.new('bin/webfont_sample.slim', pretty: true).render(self))
    end

    zipfile.add(html_sample_filename, html_sample_file)
  end

  def add_license_files(zipfile)
    ['bin/license.gpl', 'bin/license.ofl'].each do |file|
      zipfile.add(File.basename(file), file)
    end
  end
end

# encoding: UTF-8

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/rack_logger'
require './lib/rack_settings'
require './lib/font_parameters'
require './lib/font_settings'
require './lib/web_font'

class Metaflop

  include RackLogger
  include RackSettings

  # args: see FontParameter
  def initialize(args = {})
    @font_settings = FontSettings.new(args)
    @font_parameters = FontParameters.new(args, @font_settings)
  end

  def font_parameters(file = nil)
    if (!@font_parameters_initialized)
      @font_parameters.from_file file
      @font_parameters_initialized = true
    end

    @font_parameters
  end

  def font_settings
    @font_settings
  end

  def font_otf
    @font_settings.cleanup_tmp_dir
    # regenerate from the latest parameters with the sidebearings turned off
    @font_parameters.sidebearing.value = '0'
    font_parameters "#{@font_settings.out_dir}/font.mf"
    generate_mf

    command = settings[:font_otf] % @font_settings.to_hash

    `cd #{@font_settings.out_dir} && #{command}`

    @font_parameters.sidebearing.value = nil

    { :name => "#{@font_settings.font_name}.otf",
      :data => File.read("#{@font_settings.out_dir}/font.otf") }
  end

  #  returns base64 encoded otf for embedding as css fontface
  def font_preview
    @font_settings.font_hash = 'preview'
    Base64.strict_encode64 font_otf[:data]
  end

  def font_web
    font_otf
    `cd #{@font_settings.out_dir} && #{settings[:font_web]}`

    font = WebFont.new(@font_settings)
    { :name => "#{font.font_name}_webfont.zip",
      :data => font.zip }
  end

  # returns true if the mf was successfully generated
  def generate_mf
    @font_parameters.to_file
    system(
      %Q{cd #{@font_settings.out_dir} &&
         mf -halt-on-error -jobname=font font.mf > /dev/null}
    )
  end

end

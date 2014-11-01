#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class FontGenerator
  def initialize(metaflop)
    @metaflop = metaflop
  end

  def otf(preview = false)
    @metaflop.font_settings.cleanup_tmp_dir

    # regenerate from the latest parameters with the sidebearings turned off
    @metaflop.font_parameters.sidebearing.value = '0'

    @metaflop.font_parameters.to_file(preview)

    out_file = "#{@metaflop.font_settings.out_dir}/font.otf"
    settings_parameters = @metaflop.font_settings.to_hash
    settings_parameters[:timeout] = preview ? 5 : 15
    command = @metaflop.settings[:font_otf] % settings_parameters

    `cd #{@metaflop.font_settings.out_dir} && rm -f #{out_file} && #{command}`

    @metaflop.font_parameters.sidebearing.value = nil

    # if something went wrong (e.g. the timeout got triggered) the
    # output file does not exist
    unless File.exist?(out_file)
      raise Metaflop::Error::Metafont.new
    end

    { :name => "#{@metaflop.font_settings.font_name}.otf",
      :data => File.read(out_file) }
  end

  #  returns base64 encoded otf for embedding as css fontface
  def preview
    @metaflop.font_settings.font_hash = 'preview'
    data = otf(true)[:data]
    Base64.strict_encode64(data)
  end

  def web
    otf
    `cd #{@metaflop.font_settings.out_dir} && #{@metaflop.settings[:font_web]}`

    font = WebFont.new(@metaflop.font_settings)
    { :name => "#{font.font_name}_webfont.zip",
      :data => font.zip }
  end
end

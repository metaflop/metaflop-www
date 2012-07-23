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
require 'mustache'

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

  # returns an gif image for a single character preview
  def preview_single
    generate(
      generate: Mustache.render(
        %Q{latex -output-format=dvi -jobname=font "\\#{settings[:preview_single]['generate'].strip}"},
        { :text => @font_settings.char}
      ),
      convert_custom: Mustache.render("#{settings[:preview_single]['convert_custom']}", {
        :width => settings[:preview_width]
      })
    )
  end

  def preview_chart
    @font_settings.cleanup_tmp_dir
    generate(
      generate: "#{settings[:preview_chart]['generate']}",
      convert_custom: Mustache.render(settings[:preview_chart]['convert_custom'], :height => settings[:preview_height])
    )
  end

  def preview_typewriter
    @font_settings.cleanup_tmp_dir
    generate(
      generate: Mustache.render(settings[:preview_typewriter]['generate'], @font_settings),
      convert_custom: Mustache.render(settings[:preview_typewriter]['convert_custom'], :height => settings[:preview_height])
    )
  end

  def font_otf
    @font_settings.cleanup_tmp_dir
    # regenerate from the latest parameters with the sidebearings turned off
    @font_parameters.sidebearing.value = '0'
    font_parameters "#{@font_settings.out_dir}/font.mf"
    generate_mf

    command = Mustache.render(settings[:font_otf], @font_settings)

    `cd #{@font_settings.out_dir} && #{command}`

    @font_parameters.sidebearing.value = nil

    File.read("#{@font_settings.out_dir}/font.otf")
  end

  # generates the image for the specified tool chain
  #
  # @param options [Hash] optional parameters
  # @option options [String] :generate tool chain that gets executed in the tmp output dir
  # @option options [String] :convert_svg parameters for the 'convert' task for the svg image
  # @option options [String] :convert_gif parameters for the 'convert' task for the gif image
  # @option options [String] :convert_custom the custom convert call, use this instead of :convert_svg / :convert_gif
  def generate(options = {})
    convert = options[:convert_custom] || "convert #{options[:convert_svg]} #{svg_name} #{options[:convert_gif]}"

    # don't bother if metafont failed
    if generate_mf
      command = %Q{cd #{@font_settings.out_dir} &&
                   #{options[:generate]} > /dev/null &&
                   dvisvgm -TS0.75 -M16 -n  font.dvi > /dev/null &&
                   #{convert} gif:-}

        logger.info command
        # hide all output but the last one, which returns the image
        `#{command}`
    else
      logger.error "mf generation failed."
      nil
    end
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

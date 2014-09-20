#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/rack_logger'
require './app/lib/rack_settings'
require './app/lib/font_parameters'
require './app/lib/font_settings'
require './app/lib/font_generator'
require './app/lib/web_font'

class Metaflop
  include RackLogger
  include RackSettings

  # args: see FontParameters / FontSettings
  def initialize(args = {})
    @font_settings = FontSettings.new(args)
    @font_parameters = FontParameters.new(args, @font_settings)
    @font_generator = FontGenerator.new(self)
  end

  def font_parameters(file = nil)
    unless @font_parameters_initialized
      @font_parameters.from_file(file)
      @font_parameters_initialized = true
    end

    @font_parameters
  end

  def font_settings
    @font_settings
  end

  def font_otf(preview = false)
    @font_generator.otf(preview)
  end

  def font_preview
    @font_generator.preview
  end

  def font_web
    @font_generator.web
  end

  def self.create(params, settings, logger)
    # map all query params and other options
    args = {}
    (FontParameters::VALID_PARAMETERS_KEYS + FontSettings::VALID_OPTIONS_KEYS).each do |key|
      value = params[key.to_s]

      if value && !value.empty?
        args[key] = value
      end
    end

    mf = Metaflop.new(args)
    mf.settings = settings
    mf.logger = logger

    mf
  end
end

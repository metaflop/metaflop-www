#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/font_settings.rb'
require './app/lib/font_parameters_file.rb'

FontParameter = Struct.new(:value, :default, :unit, :range, :hidden)

class FontParameters
  # mf parameters
  VALID_PARAMETERS_KEYS = [
    :box_height,
    :unit_width,
    :cap_height,
    :bar_height,
    :ascender_height,
    :descender_height,
    :overshoot,
    :horizontal_increase,
    :vertical_increase,
    :aperture,
    :superness,
    :pen_size, # legacy for pen_width
    :pen_width,
    :pen_height,
    :corner,
    :contrast,
    :sidebearing,
    :glyph_angle,
    :pen_angle,
    :pen_shape,
    :taper,

    :x_height,
    :accent_height,
    :comma_depth,
    :slant,
    :craziness
  ]

  # the mapping between the defined params in the mf file and this class' properties
  MF_MAPPINGS = {
    'ht#' => :box_height,
    'u#' => :unit_width,
    'cap#' => :cap_height,
    'mean#' => :x_height,
    'bar' => :bar_height,
    'bar#' => :bar_height,
    'asc#' => :ascender_height,
    'des#' => :descender_height,
    'o#' => :overshoot,
    'incx' => :horizontal_increase,
    'incy' => :vertical_increase,
    'apert' => :aperture,
    'superness' => :superness,
    'px#' => :pen_width,
    'py#' => :pen_height,
    'corner#' => :corner,
    'cont' => :contrast,
    'sidebearing' => :sidebearing,
    'ang' => :glyph_angle,
    'penang' => :pen_angle,
    'penshape' => :pen_shape,
    'taper' => :taper,

    # fetamont additions
    'x_ht#' => :x_height,
    'acc_ht#' => :accent_height,
    'barheight#' => :bar_height,
    'comma_depth#' => :comma_depth,
    'prot' => :pen_angle,
    'slant' => :slant,
    'craziness' => :craziness
  }

  attr_accessor *VALID_PARAMETERS_KEYS

  attr_accessor :settings

  # initialize with optional options defined in VALID_OPTIONS_KEYS
  def initialize(args = {}, settings = FontSettings.new)
    @settings = settings

    VALID_PARAMETERS_KEYS.each do |key|
      instance_key = (key == :pen_size ? :pen_width : key);  # handle legacy param
      instance_value = instance_param(instance_key)
      if instance_value.nil? || instance_value.value.nil? # don't overwrite if already set
        instance_variable_set("@#{instance_key}", FontParameter.new(args[key]))
      end
    end
  end

  # loads the metafont parameter instructions (aka font.mf) from the file
  #
  # @param file [String] :file defaults to the original file containing the default parameters
  def from_file(file = nil)
    FontParametersFile.new(file: file, font_settings: @settings).each_line do |name, file_font_parameter|
      key = MF_MAPPINGS[name]

      next unless key

      font_parameter = send(key)

      if font_parameter.value.to_s.empty?
        font_parameter.value = file_font_parameter.value
      end

      font_parameter.range = file_font_parameter.range
      font_parameter.unit = file_font_parameter.unit
      font_parameter.default = file_font_parameter.default
      font_parameter.hidden = file_font_parameter.hidden
    end
  end

  # write the params to the the output dir (see @settings.out_dir)
  def to_file(use_preview_file = false)
    font_parameters = MF_MAPPINGS.map do |mapping|
      [mapping[0], instance_param(mapping[1])]
    end.to_h

    FontParametersFile.new(font_settings: @settings).save(font_parameters, use_preview_file)
  end

  # the absolute value calculated to the unit of the 'box_height' (ht#) param
  # @param key [Symbol] the symbol of the param
  # @param value [Symbol] the value of the param (recursively calculated, no need to pass initially)
  def absolute_value(key, value = instance_param(key).value.to_f)
    param = instance_param(key)
    if param && param.unit && param.unit != @box_height.unit
      key = param.unit
      value = instance_param(key).value.to_f * value
      absolute_value(key, value)
    else
      value
    end
  end

  # @param key [String] / [Symbol] either the metafont param name or the instance variable name
  def instance_param(key)
    if VALID_PARAMETERS_KEYS.include?(key.to_sym)
      instance_variable_get("@#{key}")
    elsif MF_MAPPINGS.key?(key.to_s)
      instance_variable_get("@#{MF_MAPPINGS[key.to_s]}")
    else
      nil
    end
  end
end

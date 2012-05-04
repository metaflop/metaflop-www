#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/font_settings.rb'

FontParameter = Struct.new(:value, :default, :unit, :range, :hidden)

class FontParameters

  # mf parameters
  VALID_PARAMETERS_KEYS = [
    :box_height,
    :unit_width,
    :cap_height,
    :mean_height,
    :bar_height,
    :ascender_height,
    :descender_height,
    :overshoot,
    :horizontal_increase,
    :vertical_increase,
    :apperture,
    :superness,
    :pen_size, # legacy for pen_width
    :pen_width,
    :pen_height,
    :corner,
    :contrast,
    :sidebearing,
    :glyph_angle,
    :pen_angle,
    :pen_shape
  ]

  # the mapping between the defined params in the mf file and this class' properties
  MF_MAPPINGS = {
    'ht#' => :box_height,
    'u#' => :unit_width,
    'cap#' => :cap_height,
    'mean#' => :mean_height,
    'bar' => :bar_height,
    'bar#' => :bar_height,
    'asc#' => :ascender_height,
    'des#' => :descender_height,
    'o#' => :overshoot,
    'incx' => :horizontal_increase,
    'incy' => :vertical_increase,
    'appert' => :apperture,
    'superness' => :superness,
    'px#' => :pen_width,
    'py#' => :pen_height,
    'corner#' => :corner,
    'cont' => :contrast,
    'sidebearing' => :sidebearing,
    'ang' => :glyph_angle,
    'penang' => :pen_angle,
    'penshape' => :pen_shape
  }

  attr_accessor *VALID_PARAMETERS_KEYS

  attr_accessor :settings

  # initialize with optional options defined in VALID_OPTIONS_KEYS
  def initialize(args = {}, settings = FontSettings.new)
    @settings = settings

    VALID_PARAMETERS_KEYS.each do |key|
      instance_key = (key == :pen_size ? :pen_width : key);  # handle legacy param
      instance_value = instance_param(instance_key.to_sym)
      if instance_value.nil? || instance_value.value.nil? # don't overwrite if already set
        instance_variable_set("@#{instance_key}".to_sym, FontParameter.new(args[key]))
      end
    end
  end

  # loads the metafont parameter instructions (aka font.mf) from the file
  #
  # @param file [String] :file defaults to the original file containing the default parameters
  def from_file(file = nil)
    file = original_file if file.nil?
    lines = File.open(file, 'r:utf-8'){ |f| f.readlines }
    # in case the file is a one-liner already, split each statement onto a line
    lines = lines[0].split(';').map{ |x| "#{x};" } if lines.length == 1

    lines.delete_if do |x|            # remove comment and empty lines
      stripped = x.strip
      stripped == '' || stripped[0] == '%'
    end
    .each do |x|                  # remove comments at the end of the line
      pair = x[/([^%]+)/, 0].strip
      splits = pair.split(':=')

      if (splits.length == 2)
        # replace the value from the file if we have a value set for the parameter
        value_from_file = splits[1].to_f
        mapping = MF_MAPPINGS[splits[0]]
        param = mapping ? send(mapping) : nil
        value = if param && param.value && !param.value.to_s.empty?
                  param.value
                else
                  value_from_file
                end

        # range
        range = x.gsub(/\s+/, '').scan(/\$([\d\.]+)\w*\/([\d\.]+)\w*$/).flatten!
        range = [0, 1] if range.nil?

        instance_variable_set "@#{mapping}".to_sym, FontParameter.new(
          value, # value
          value_from_file, # default
          splits[1][/[^\d;\.]+/], # unit
          { :from => range[0], :to => range[1] }, # range
          (x.include? '@hidden') # hidden
        )
      end
    end
  end

  # write the params to the the output dir (see @settings.out_dir)
  def to_file
    content = File.open(original_file, 'r:utf-8'){ |f| f.read }
    # replace the original values
    MF_MAPPINGS.each do |mapping|
      param = instance_param mapping[1]
      unless param.value.nil?
        content.gsub! /(#{mapping[0]}:=)[\d\/\.]+/, "\\1#{param.value}"
      end
    end

    File.open(File.join(@settings.out_dir, 'font.mf'), "w:utf-8") do |file|
      file.write(content)
    end
  end

  # the absolute value calculated to the unit of the 'box_height' (ht#) param
  # @param key [Symbol] the symbol of the param
  # @param value [Symbol] the value of the param (recursively calculated, no need to pass initially)
  def absolute_value(key, value = instance_param(key).value.to_f)
    param = instance_param(key)
    if !param.nil? && !param.unit.nil? && param.unit != @box_height.unit
      key = param.unit.to_sym
      value = instance_param(key).value.to_f * value
      absolute_value(key, value)
    else
      value
    end
  end

  # @param key [String] / [Symbol] either the metafont param name or the instance variable name
  def instance_param(key)
    return instance_variable_get("@#{key.to_sym}") if VALID_PARAMETERS_KEYS.include?(key.to_sym)
    return instance_variable_get("@#{MF_MAPPINGS[key.to_s]}") unless MF_MAPPINGS[key.to_s].nil?
    nil
  end

  def original_file
    "mf/metaflop-font-#{@settings.fontface.downcase}/font.mf"
  end

end

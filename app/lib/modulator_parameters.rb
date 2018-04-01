#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'json'

class ModulatorParameters
  def initialize(font_parameters)
    @font_parameters = font_parameters
  end

  def default_parameters
    [
      dimension_default_parameters,
      proportion_default_parameters,
      shape_default_parameters,
      optical_corrections_parameters
    ]
  end

  def all
    tab_index = 1

    # add properties needed for view
    all_with_each_item do |item|
      param = @font_parameters.send(item[:key])

      base!(item, param)
      dropdowns!(item, param)
      dependencies!(item, param)

      item[:tabindex] = tab_index

      tab_index += 1
    end
  end

  private

  def all_with_each_item
    groups = default_parameters

    groups.each do |group|
      group[:items].each do |item|
        yield item
      end

      # remove non-mapped params
      group[:items].reject! { |item| !item[:default] || item[:hidden] }
    end

    # remove empty groups
    groups.reject! { |group| group[:items].empty? }

    groups
  end

  def dimension_default_parameters
    {
      title: 'Dimension',
      items: [
        { title: 'unit width', key: :unit_width },
        { title: 'pen width', key: :pen_width },
        { title: 'pen height', key: :pen_height }
      ]
    }
  end

  def proportion_default_parameters
    {
      title: 'Proportion',
      items: [
        { title: 'cap height', key: :cap_height },
        { title: 'bar height', key: :bar_height },
        { title: 'asc. height', key: :ascender_height },
        { title: 'desc. height', key: :descender_height },
        { title: 'glyph angle', key: :glyph_angle },
        { title: 'x-height', key: :x_height },
        { title: 'accents height', key: :accent_height },
        { title: 'depth of comma', key: :comma_depth }
      ]
    }
  end

  def shape_default_parameters
    {
      title: 'Shape',
      items: [
        { title: 'horiz. increase', key: :horizontal_increase },
        { title: 'vert. increase', key: :vertical_increase },
        { title: 'contrast', key: :contrast },
        { title: 'superness', key: :superness },
        { title: 'pen angle', key: :pen_angle },
        { title: 'pen shape', key: :pen_shape, options: [
          { value: '1', text: 'circle' },
          { value: '2', text: 'square' },
          { value: '3', text: 'razor' }
        ]},
        { title: 'slanting', key: :slant },
        { title: 'randomness', key: :craziness },
        { title: 'drawing style', key: :drawing_style, options: [
          { value: '1', text: 'line' },
          { value: '2', text: 'dots' },
          { value: '3', text: 'overdraw' }
        ]},
        { title: 'number of points', key: :number_of_points, dependent: { drawing_style: [2, 3] }},
        { title: 'serifs', key: :serifs }
      ]
    }
  end

  def optical_corrections_parameters
    {
      title: 'Optical corrections',
      items: [
        { title: 'aperture', key: :aperture },
        { title: 'corner', key: :corner },
        { title: 'overshoot', key: :overshoot },
        { title: 'taper', key: :taper }
      ]
    }
  end

  def base!(item, param)
    item[:default] = param.default
    item[:value] = param.value
    item[:range_from] = param.range && param.range[:from]
    item[:range_to] = param.range && param.range[:to]
    item[:hidden] = param.hidden
    item[:name] = item[:key]
  end

  def dropdowns!(item, param)
    if item[:options]
      item[:dropdown] = true
      selected = item[:options].first { |option| option[:value] == param.value }
      selected[:selected] = true if selected
    end
  end

  def dependencies!(item, param)
    if item[:dependent]
      item[:dependent] = JSON.generate(item[:dependent])
    end
  end
end

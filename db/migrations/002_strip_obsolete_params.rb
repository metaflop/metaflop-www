Sequel.migration do
  up do
    Url.each do |url|
      fontface = url.params['fontface']
      valid_params =
        case fontface
        when 'Adjuster'
          %w(
          fontface
          glyph_angle
          pen_angle
          pen_height
          pen_shape
          pen_width
          unit_width
          )
        when 'Bespoke'
          %w(
          apperture
          ascender_height
          bar_height
          cap_height
          contrast
          corner
          descender_height
          fontface
          horizontal_increase
          overshoot
          pen_width
          superness
          taper
          unit_width
          vertical_increase
          x_height
          )

        when 'Fetamont'
          %w(
          accent_height
          bar_height
          comma_depth
          craziness
          fontface
          pen_angle
          pen_height
          pen_width
          slant
          superness
          unit_width
          x_height
          )
        end

      if valid_params
        url.params.select! { |k, v| valid_params.include?(k) }
        url.save
      end
    end
  end

  down {}
end

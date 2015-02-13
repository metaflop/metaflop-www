#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/modulator_parameters'

class App < Sinatra::Base
  module Views
    class Modulator < Layout
      include LogicLessSlim

      def parameters
        ModulatorParameters.new(@font_parameters).all
      end

      # single preview char chooser
      # [{ items: [] }, { items: [] } ]
      def char_sets
        ['A'..'Z', 'a'..'z', 0..9].map do |set|
          {
            items: set.map do |item|
              { char: item, css_class: item == 'A' ? 'active' : '' }
            end
          }
        end
      end

      def fontfaces
        @settings.metafonts.keys.map(&:titleize).map do |fontface|
          { name: fontface, active: @active_fontface == fontface }
        end
      end

      def typewriter_font_sizes
        [16, 24, 32, 48].map do |size|
          {
            value: size,
            text: "#{size}px",
            selected: size == 32
          }
        end
      end

      def char_chooser
        slim :char_chooser, layout: false
      end

      def parameter_panel
        slim :parameter_panel, layout: false
      end

      def clippy_url
        asset_path('flash/clippy.swf')
      end
    end
  end
end

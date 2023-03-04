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
        [16, 24, 32, 48, 96].map do |size|
          {
            value: size,
            text: "#{size}px",
            selected: size == 32
          }
        end
      end

      def typewriter_texts
        [
          {
            text: 'Font design is in fact…',
            value: 'Font design is in fact lots of fun, especially when you make mistakes.',
            selected: true
          },
          {
            text: 'A top-notch designer…',
            value: "«A top-notch designer of typefaces needs to have an unusually good eye and a highly developed sensitivity to the nuances of shapes. A top-notch user of computer languages needs to have an unusual talent for abstract reasoning and a highly developed ability to express intuitive ideas in formal terms. Very few people have both of these unusual combinations of skills; hence the best products of METAFONT will probably be collaborative efforts between two people who complement each other’s abilities. Indeed, this situation isn’t very different from the way types have been created for many generations, except that the role of “punch-cutter” is now being played by skilled computer specialists instead of by skilled metal-workers.»\n\nThe METAFONT book, Donald E. Knuth, 1986, p.v",
            selected: false
          },
          {
            text: 'ABC abc 0123',
            value: "ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n.,:;«»-+/()!?&",
            selected: false
          }
        ]
      end

      def default_typewriter_text
        typewriter_texts.first[:value]
      end

      def char_chooser
        slim :char_chooser, layout: false
      end

      def parameter_panel
        slim :parameter_panel, layout: false
      end

      def anatomy_images
        fontfaces.map do |fontface|
          {
            name: fontface[:name],
            css_class: fontface[:active] ? 'active' : '',
            url: image_path("anatomy-#{fontface[:name].downcase}.svg")
          }
        end
      end
    end
  end
end

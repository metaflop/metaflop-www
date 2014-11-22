#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
  module Views
    class Modulator < Layout
      include LogicLessSlim

      def parameters
        groups = [{
          :title => "Dimension",
          :items => [
            { :title => 'unit width', :key => :unit_width },
            { :title => 'pen width', :key => :pen_width },
            { :title => 'pen height', :key => :pen_height }
          ]
        }, {
          :title => "Proportion",
          :items => [
            { :title => 'cap height', :key => :cap_height },
            { :title => 'bar height', :key => :bar_height },
            { :title => 'ascender height', :key => :ascender_height },
            { :title => 'descender height', :key => :descender_height },
            { :title => 'glyph angle', :key => :glyph_angle },
            { :title => 'x-height', :key => :x_height },
            { :title => 'accents height', :key => :accent_height },
            { :title => 'depth of comma', :key => :comma_depth },
          ]
        }, {
          :title => "Shape",
          :items => [
            { :title => 'horizontal increase', :key => :horizontal_increase },
            { :title => 'vertical increase', :key => :vertical_increase },
            { :title => 'contrast', :key => :contrast },
            { :title => 'superness', :key => :superness },
            { :title => 'pen angle', :key => :pen_angle },
            { :title => 'pen shape', :key => :pen_shape, :options =>
              [ { :value => '1', :text => 'Circle' },
                { :value => '2', :text => 'Square' },
                { :value => '3', :text => 'Razor' } ] },
            { :title => 'slanting', :key => :slant },
            { :title => 'randomness', :key => :craziness }
          ]
        }, {
          :title => "Optical corrections",
          :items => [
            { :title => 'apperture', :key => :apperture },
            { :title => 'corner', :key => :corner },
            { :title => 'overshoot', :key => :overshoot },
            { :title => 'taper', :key => :taper },
          ]
        }]

        # add properties needed for view
        i = 1
        groups.each do |group|
          group[:items].each do |x|
            param = @font_parameters.send(x[:key])
            x[:default] = param.default
            x[:value] = param.value
            x[:range_from] = param.range.nil? ? nil : param.range[:from]
            x[:range_to] = param.range.nil? ? nil : param.range[:to]
            x[:hidden] = param.hidden
            x[:name] = x[:key]
            x[:tabindex] = i

            # special case for dropdowns
            if x[:options]
              x[:dropdown] = true
              selected = x[:options].select { |option| option[:value] == param.value }.first
              if selected
                selected[:selected] = true
              end
            end

            i = i + 1
          end
          .keep_if { |x| x[:default] && !x[:hidden] } # remove non-mapped params
        end

        # remove empty groups
        groups.delete_if { |x| x[:items].empty? }

        groups
      end

      # single preview char chooser
      # [{ :items => [] }, { :items => [] } ]
      def char_sets
        ['A'..'Z', 'a'..'z', 0..9].map do |set|
          {
            :items => set.map do |item|
              { :char => item, :css_class => item == 'A' ? 'active' : '' }
            end
          }
        end
      end

      def fontfaces
        %w(Adjuster Bespoke Fetamont).map do |x|
          { :name => x, :active => @active_fontface == x }
        end
      end

      def char_chooser
        slim :char_chooser, :layout => false
      end

      def parameter_panel
        slim :parameter_panel, :layout => false
      end

      def typoglossary_image_url
        image_path('typoglossary.png')
      end
    end
  end
end

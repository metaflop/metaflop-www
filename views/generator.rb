#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
    module Views
        class Generator < Layout

            attr_accessor :chars

            def js
                ['/js/generator.js']
            end

            def parameters
                groups = [
                    {
                        :title => "Dimension",
                        :items => [
                            { :title => 'unit width', :key => :unit_width },
                            { :title => 'overshoot', :key => :overshoot },
                            { :title => 'pen width', :key => :pen_width },
                            { :title => 'pen height', :key => :pen_height }
                        ]
                    },
                    {
                        :title => "Proportion",
                        :items => [
                            { :title => 'cap height', :key => :cap_height },
                            { :title => 'mean height', :key => :mean_height },
                            { :title => 'bar height', :key => :bar_height },
                            { :title => 'ascender height', :key => :ascender_height },
                            { :title => 'descender height', :key => :descender_height }
                        ]
                    },
                    {
                        :title => "Shape",
                        :items => [
                            { :title => 'horizontal increase', :key => :horizontal_increase },
                            { :title => 'vertical increase', :key => :vertical_increase },
                            { :title => 'apperture', :key => :apperture },
                            { :title => 'contrast', :key => :contrast },
                            { :title => 'superness', :key => :superness },
                            { :title => 'corner', :key => :corner },
                            { :title => 'pen angle', :key => :pen_angle },
                            { :title => 'pen shape', :key => :pen_shape, :html => '<select id="pen-shape"><option value="1">Circle</option><option value="2">Square</option><option value="3">Razor</option><select>'}
                        ]
                    }
                ]

                # add properties needed for view
                i = 1
                groups.each do |group|
                    group[:items].each do |x|
                        param = @font_parameters.send(x[:key])
                        puts param
                        x[:default] = param.default
                        x[:value] = param.value
                        x[:range] = param.range
                        x[:name] = x[:title].gsub(' ', '-') # (css class compliant)
                        x[:tabindex] = i
                        i = i + 1
                    end
                    .delete_if { |v| !v[:default] } # remove non-mapped params
                end

                # remove empty groups
                groups.delete_if { |x| x[:items].empty? }

                groups
            end

            # single preview char chooser
            # [{ :items => [] }, { :items => [] } ]
            def char_sets
                number = 0
                [:uc, :lc, :num, :punct].map{ |type| @chars[type] }.delete_if(&:empty?).map do |set|
                    {
                        :items => set.map do |item|
                            number = number + 1
                            { :title => item, :number => number, :active => number == 1 }
                        end
                    }
                end
            end

            def fontfaces
                %w(Bespoke Adjuster).map do |x|
                    { :name => x, :active => @active_fontface == x }
                end
            end
        end

    end
end

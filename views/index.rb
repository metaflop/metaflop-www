#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
    module Views
        class Index < Layout

            def parameters
                groups = [
                    {
                        :title => "Dimension",
                        :items => [
                            { :title => 'box height', :key => :ht, :html => '<div class="static-value">100%</div>' },
                            { :title => 'unit width', :key => :u },
                            { :title => 'overshoot', :key => :o },
                            { :title => 'pen size', :key => :px }
                        ]
                    },
                    {
                        :title => "Proportion",
                        :items => [
                            { :title => 'cap height', :key => :cap },
                            { :title => 'mean height', :key => :mean },
                            { :title => 'bar height', :key => :bar },
                            { :title => 'ascender height', :key => :asc },
                            { :title => 'descender height', :key => :des }
                        ]
                    },
                    {
                        :title => "Shape",
                        :items => [
                            { :title => 'horizontal increase', :key => :incx },
                            { :title => 'vertical increase', :key => :incy },
                            { :title => 'apperture', :key => :appert },
                            { :title => 'contrast', :key => :cont },
                            { :title => 'superness', :key => :superness },
                            { :title => 'corner', :key => :corner },
                            { :title => 'pen angle', :key => :penang },
                            { :title => 'pen shape', :key => :penshape, :html => '<select id="pen-shape"><option value="1">Circle</option><option value="2">Square</option><option value="3">Razor</option><select>'}
                        ]
                    }
                ]

                # add properties needed for view
                i = 1
                groups.each do |group|
                    group[:items].each do |x|
                        key = x[:key]
                        x[:default] = defaults[key]
                        x[:value] = values[key]
                        x[:range] = ranges[key]
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
            def char_sets
                number = 0
                [
                    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
                    ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
                ].map do |set|
                    {
                        :items => set.map do |item|
                            number = number + 1
                            { :title => item, :number => number }
                        end
                    }
                end
            end

            def values
                @values
            end

            def defaults
                @defaults
            end

            def ranges
                @ranges
            end

            def fontfaces
                %w(Bespoke Adjuster).map do |x|
                    { :name => x, :active => @active_fontface == x }
                end
            end
        end

    end
end

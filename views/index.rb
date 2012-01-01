class App
    module Views
        class Index < Layout

            def parameters
                groups = [
                    {
                        :title => "Dimension",
                        :items => [
                            { :title => 'box height', :html => '<div class="static-value">100%</div>' },
                            { :title => 'unit width', :default => defaults[:u] }
                        ]
                    },
                    {
                        :title => "Proportion",
                        :items => [
                            { :title => 'cap height', :default => defaults[:cap] },
                            { :title => 'mean height', :default => defaults[:mean] },
                            { :title => 'bar height', :default => defaults[:bar] },
                            { :title => 'ascender height', :default => defaults[:asc] },
                            { :title => 'descender height', :default => defaults[:desc] },
                            { :title => 'overshoot', :default => defaults[:o] }
                        ]
                    },
                    {
                        :title => "Shape",
                        :items => [
                            { :title => 'horizontal increase', :default => defaults[:incx] },
                            { :title => 'vertical increase', :default => defaults[:incy] },
                            { :title => 'apperture', :default => defaults[:appert] },
                            { :title => 'superness', :default => defaults[:superness] }
                        ]
                    },
                    {
                        :title => "Drawing mode",
                        :items => [
                            { :title => 'pen size', :default => defaults[:px] },
                            { :title => 'corner', :default => defaults[:corner] },
                            { :title => 'contrast', :default => defaults[:cont] }
                        ]
                    }
                ]

                # add a name (css class compliant)
                groups.each do |group|
                    group[:items].each do |x|
                        x[:name] = x[:title].gsub(' ', '-')
                    end
                end
            end

            # single preview char chooser
            def char_sets
                number = 0
                [
                    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'],
                    ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'],
                    [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
                ].map do |set|
                    {
                        :items => set.map do |item|
                            number = number + 1
                            { :title => item, :number => number }
                        end
                    }
                end
            end

            def defaults
                @defaults
            end
        end

    end
end

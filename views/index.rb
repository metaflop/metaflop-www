class App
    module Views
        class Index < Layout

            def parameters
                groups = [
                    {
                        :title => "Dimension",
                        :items => [
                            { :title => 'box height', :html => '<div class="static-value">100%</div>' },
                            { :title => 'unit width', :default => defaults[:u], :range => ranges[:u] },
                            { :title => 'overshoot', :default => defaults[:o], :range => ranges[:o] },
                            { :title => 'pen size', :default => defaults[:px], :range => ranges[:px] }
                        ],
                        :css_class => "first"
                    },
                    {
                        :title => "Proportion",
                        :items => [
                            { :title => 'cap height', :default => defaults[:cap], :range => ranges[:cap] },
                            { :title => 'mean height', :default => defaults[:mean], :range => ranges[:mean] },
                            { :title => 'bar height', :default => defaults[:bar], :range => ranges[:bar] },
                            { :title => 'ascender height', :default => defaults[:asc], :range => ranges[:asc] },
                            { :title => 'descender height', :default => defaults[:des], :range => ranges[:des] }
                        ]
                    },
                    {
                        :title => "Shape",
                        :items => [
                            { :title => 'horizontal increase', :default => defaults[:incx], :range => ranges[:incx] },
                            { :title => 'vertical increase', :default => defaults[:incy], :range => ranges[:incy] },
                            { :title => 'apperture', :default => defaults[:appert], :range => ranges[:appert] },
                            { :title => 'contrast', :default => defaults[:cont], :range => ranges[:cont] },
                            { :title => 'superness', :default => defaults[:superness], :range => ranges[:superness] },
                            { :title => 'corner', :default => defaults[:corner], :range => ranges[:corner] }
                        ]
                    }
                ]

                # add a name (css class compliant) and tab index
                i = 1
                groups.each do |group|
                    group[:items].each do |x|
                        x[:name] = x[:title].gsub(' ', '-')
                        x[:tabindex] = i
                        i = i + 1
                    end

                    # add css class to last item
                    group[:items][-1][:css_class] = "last"
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

            def ranges
                @ranges
            end
        end

    end
end

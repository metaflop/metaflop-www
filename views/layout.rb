class App
    module Views
        class Layout < Mustache
            def title
                @title || "metaflop"
            end
        end
    end
end

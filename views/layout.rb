#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
    module Views
        class Layout < Mustache
            def title
                @title || "metaflop"
            end

            def css
                []
            end

            def js
                []
            end

            def main_navigation
               @main_navigation 
            end

            def meta_navigation
               @meta_navigation 
            end
        end
    end
end

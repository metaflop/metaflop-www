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
        end
    end
end

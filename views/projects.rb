#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
    module Views
        class Projects < Layout
            def js
                ['/js/basic-jquery-slider.min.js', '/js/projects.js']
            end

            def css
                ['/assets/css/basic-jquery-slider.scss']
            end
        end
    end
end

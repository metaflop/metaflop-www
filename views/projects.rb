#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/rack_settings'

class App
    module Views
        class Projects < Layout

            include RackSettings

            def js
                ['/js/basic-jquery-slider.min.js', '/js/projects.js']
            end

            def css
                ['/assets/css/basic-jquery-slider.scss']
            end

            def single(name)
                settings[name]
            end

            def all
                all = settings.to_a.map{ |x| x[1]["title"] = x[0]; x[1] }
                all[0]["active"] = true
                all
            end

            def first
                all[0]
            end
        end
    end
end

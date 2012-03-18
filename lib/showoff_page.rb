#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/rack_settings'

module ShowoffPage
    include RackSettings

    def js
        ['/js/basic-jquery-slider.min.js', "/js/showoff-page.js"]
    end

    def css
        ['/assets/css/basic-jquery-slider.scss']
    end

    def page_title
        self.class.name.split('::').last
    end

    def page_name
        page_title.downcase
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

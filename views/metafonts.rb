#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/showoff_page'

class App
  module Views
    class Metafonts < Layout
      include ShowoffPage
    end
  end
end

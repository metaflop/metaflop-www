#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require_relative 'showoff_page'

class App
  module Views
    class Metafonts < ShowoffPage
      template :showoff_page
    end
  end
end

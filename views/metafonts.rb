#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require_relative 'showoff_page'
require './lib/slideshow_page'

class App
  module Views
    class Metafonts < ShowoffPage
      template :showoff_page

      include ::SlideshowPage
    end
  end
end

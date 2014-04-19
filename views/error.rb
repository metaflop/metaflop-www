#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#
require './views/layout'

class App
  module Views
    class Error < Layout
      def image
        error_code = self.class.name[/\d+/]
        image = Dir["assets/images/errors/#{error_code}/*"].sample
        image_path(image.sub(/assets\/images\//, ''))
      end
    end
  end
end

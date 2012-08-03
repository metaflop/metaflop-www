#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App
  module Views
    class News < Layout
      include SlideshowPage

      def images
        (1..12).map { |i| "img/helloworld/bespoke-helloworld-%02d.png" % i}
      end
    end
  end
end

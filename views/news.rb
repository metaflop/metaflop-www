#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#
require './lib/slideshow_page'

class App
  module Views
    class News < Layout
      include ::SlideshowPage

      # randomly create a sequence of 12 images,
      # varying by language, keeping the order
      def images
        random = Random.new
        (1..12).map do |i|
          random_lang = %w{de en fr it}[random.rand(0..3)]
          "img/helloworld/bespoke-helloworld-%02d-%s.png" % [i, random_lang]
        end
      end
    end
  end
end

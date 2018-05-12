#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/views/layout'

class App < Sinatra::Base
  module Views
    class News < Layout
      attr_reader :settings

      def page_title
        'Hello World'
      end

      # randomly create a sequence of 12 images from each family, varying by
      # language, keeping the order
      def images
        files = Dir['assets/images/helloworld/*']

        settings.metafonts.keys.map do |font_family|
          (1..12).map do |i|
            files.select { |x|
              x =~ /#{"%s-helloworld-%02d-" % [font_family, i]}/
            }.sample
          end
        end.flatten.map { |image|
          image_path(image.sub(/assets\/images\//, ''))
        }.shuffle
      end
    end
  end
end

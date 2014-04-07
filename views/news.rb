#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#
require './views/layout'
require './lib/slideshow_page'

class App
  module Views
    class News < Layout
      include ::SlideshowPage

      # randomly create a sequence of 12 images,
      # varying by language, keeping the order
      def images
        files = Dir['public/img/helloworld/*'].map { |x| x.sub 'public', '' }

        %w(adjuster bespoke).map do |font_family|
          (1..12).map do |i|
            files.select do |x|
              x =~ /#{"%s-helloworld-%02d-" % [font_family, i]}/
            end.sample
          end
        end.flatten.shuffle
      end
    end
  end
end

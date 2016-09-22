#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require_relative 'showoff_page'

class App < Sinatra::Base
  module Views
    class Showcases < ShowoffPage
      template :showcases

      def all
        pages = @settings.to_a.map do |x|
          {
            identifier: x[0],
            title: x[1]['title'],
            description: x[1]['description'],
            design: x[1]['design'],
            publisher: x[1]['publisher'],
            year: x[1]['year'],
            font: x[1]['font'],
            images: x[1]['images'].map do |img|
            {
              url: image_path("#{page_slug}/#{img}"),
            }
            end
          }
        end

        # sort by year descending, title ascending
        pages.sort! { |a, b| [b[:year], a[:title]] <=> [a[:year], b[:title]] }

        current(pages)['css_class'] = 'active'
        pages
      end
    end
  end
end

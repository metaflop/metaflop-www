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
            agency: x[1]['agency'],
            year: x[1]['year'],
            font: x[1]['font'],
            images: x[1]['images'].map do |img|
            {
              url: image_path("#{page_slug}/#{img[0]}"),
              title: img[1]
            }
            end,
              subimages: (x[1]['subimages'] || []).map.with_index do |img, i|
              {
                url: image_path("#{page_slug}/#{img[0]}"),
                short: img[1],
                  first: i == 0
              }
              end
          }
        end

        current(pages)['css_class'] = 'active'
        pages
      end
    end
  end
end

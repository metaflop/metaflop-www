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
    class Metafonts < ShowoffPage
      template :showoff_page

      def all
        pages = @settings.to_a.map do |identifier, settings|
          infos = infos(identifier, settings)
          images = images(settings)
          sub_images = sub_images(settings)

          infos
            .merge(images)
            .merge(sub_images)
        end

        current(pages)['css_class'] = 'active'

        pages
      end

      private

      def infos(identifier, settings)
        {
          identifier: identifier,
          title: identifier,
          description: settings['description'],
          type_designer: with_last_identifier(settings['type_designer']),
          year: settings['year'],
          encoding: settings['encoding'],
          source_code: with_last_identifier(settings['source_code'])
        }
      end

      def images(settings)
        {
          images: settings['images'].map do |img|
            {
              url: image_path("#{page_slug}/#{img.first}"),
              title: img.last
            }
          end
        }
      end

      def sub_images(settings)
        {
          subimages: (settings['subimages'] || []).map.with_index do |img, i|
            {
              url: image_path("#{page_slug}/#{img.first}"),
              short: img.last,
              first: i == 0
            }
          end
        }
      end
    end
  end
end

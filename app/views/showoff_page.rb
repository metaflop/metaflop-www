#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App < Sinatra::Base
  module Views
    class ShowoffPage < Layout
      def page_subtitle
        current[:title]
      end

      def current(pages = nil)
        pages ||= all
        unless @subpage.nil?
          pages.find { |x| x[:identifier] == @subpage }
        else
          pages[0]
        end
      end

      private

      def with_last_identifier(collection)
        collection.map do |item|
          item[:last] = item == collection.last
          item
        end
      end
    end
  end
end

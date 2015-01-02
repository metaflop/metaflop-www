#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

class App < Sinatra::Base
  module Views
    class Layout
      include Sprockets::Helpers

      def self.template(template = nil)
        @template ||= template
      end

      def application_name
        'Metaflop'
      end

      # the page's main title, e.g. 'Modulator'
      def page_title
        self.class.name.split('::').last
      end

      # the page's subtitle, e.g. 'Adjuster' for
      # the 'metafont' subpage 'adjuster'.
      def page_subtitle
      end

      # the slug of the page. it's used as css
      # class name and for the image paths.
      def page_slug
        page_title.downcase.gsub(' ', '_')
      end

      # the title of the page (i.e. html <title> tag), which
      # is shown in the browser title bar.
      def page_tag_title
        full_title = [page_title, page_subtitle].compact.join(' ')

        "#{full_title} | #{application_name}".downcase
      end

      def application_stylesheet_path
        stylesheet_path 'app'
      end

      def application_javascript_path
        javascript_path 'app'
      end
    end
  end
end

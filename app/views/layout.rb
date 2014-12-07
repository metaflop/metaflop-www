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

      def title
        @title || "metaflop"
      end

      def page_title
        self.class.name.split('::').last
      end

      def page_name
        page_title.downcase
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

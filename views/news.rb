#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './views/layout'

class App
  module Views
    class News < Layout
      include DataMapper::Resource

      property :id, Serial
      property :created_at, DateTime
      property :facebook_id, String, :length => 50
      property :title, String, :required => true, :length => 255
      property :text, Text, :required => true
      property :published_at, DateTime
      property :data, Yaml

      def data=(data)
        data = YAML.dump(data)
        super
      end

      def data
        data = YAML.load(super)
      end
    end
  end
end

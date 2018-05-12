#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/routes/base'

module Routes
  class Home < Base
    get '/' do
      @settings = settings

      slim :news, http_caching: false
    end
  end
end

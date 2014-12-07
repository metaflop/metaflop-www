#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/views/modulator.rb'

class App < Sinatra::Base
  module Views
    class CharChooser < Modulator
    end
  end
end

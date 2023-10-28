#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# sinatra/base won't work because of simple navigation
require 'active_support'
require 'sinatra'
require 'backports/rails'
Dir['./app/routes/*.rb'].each { |route| require route }

class App < Sinatra::Base
  include Configuration
  configure_root_application

  use Routes::Redirects
  use Routes::Home
  use Routes::Modulator
  use Routes::Pages
end

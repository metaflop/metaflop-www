#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# sinatra/base won't work because of simple navigation
require 'sinatra'
require 'active_support'
Dir['./app/routes/*.rb'].each { |route| require route }

class App < Sinatra::Base
  include Configuration
  configure_asset_pipeline

  use Routes::Redirects
  use Routes::Home
  use Routes::Modulator
  use Routes::Pages
end

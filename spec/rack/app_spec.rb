#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app.rb'
require 'rack/test'
require 'json'

set :environment, :test

describe 'metaflop app' do
  include Rack::Test::Methods

  def app
    App
  end

  it 'news' do
    get '/'
    last_response.should be_ok
    last_response.body.should include 'hello world'
  end
end

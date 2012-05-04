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
    last_response.body.should include 'News'
  end

  it 'valid project returns the json data' do
    get '/projects/lovehate.json'
    last_response.should be_ok
    json = JSON.parse last_response.body
    json['description'].should_not be_nil
    json['images'].length.should > 0
  end

  it 'invalid project returns 404' do
    get '/projects/asdf.json'
    last_response.status.should == 404
  end
end

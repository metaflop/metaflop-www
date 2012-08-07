#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# encoding: UTF-8
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'sinatra/simple-navigation'
require 'sass'
require 'mustache/sinatra'
require 'time'
require 'data_mapper' # metagem, requires common plugins too.
require './lib/metaflop'
require './lib/url'

class App < Sinatra::Application

  configure do
    register Sinatra::ConfigFile
    config_file ['./config.yml', './db.yml']

    register Sinatra::SimpleNavigation

    # setup the tmp dir where the generated fonts go
    tmp_dir = "/tmp/metaflop"
    FileUtils.rm_rf(tmp_dir)
    Dir.mkdir(tmp_dir)

    require './views/layout'
    register Mustache::Sinatra

    set :mustache, {
      :views => './views',
      :templates => './views'
    }

    mime_type :otf, 'font/opentype'

    enable :sessions

    # db
    DataMapper.setup(:default, {
      :adapter  => settings.db[:adapter],
      :host     => settings.db[:host],
      :username => settings.db[:username],
      :password => settings.db[:password],
      :database => settings.db[:database]
    })

    DataMapper.finalize
    Url.auto_upgrade!
  end

  configure :development do
    register Sinatra::Reloader
    also_reload '**/*.rb'
    dont_reload '**/*spec.rb'
  end

  configure :production do
    # logging
    log_dir = "log/rack/"
    Dir.mkdir(log_dir) unless Dir.exist? log_dir
    logger = File.new("#{log_dir}#{Time.new.iso8601}.log", 'w+')
    $stderr.reopen(logger)
    $stdout.reopen(logger)
  end

  before do
    @main_navigation = render_navigation :context => :main
    @meta_navigation = render_navigation :context => :meta
  end

  get '/' do
    mustache :news
  end

  get '/modulator' do
    mf = mf_instance_from_request
    @font_parameters = mf.font_parameters
    @active_fontface = mf.font_settings.fontface

    mustache :modulator
  end

  # creates a shortened url for the current params (i.e. font setting)
  get '/modulator/font/create' do
    Url.create(:params => params)[:short]
  end

  get '/modulator/font/:url' do |url|
    url = Url.first(:short => url)

    if url.nil?
      redirect '/'
    end

    mf = mf_instance_from_request url[:params]
    @font_parameters = mf.font_parameters
    @active_fontface = mf.font_settings.fontface

    mustache :modulator
  end

  # redirect for legacy short urls
  get '/font/:url' do |url|
    redirect to "/modulator/font/#{url}"
  end

  get '/assets/css/:name.scss' do |name|
    require './views/scss/bourbon/lib/bourbon.rb'
    content_type :css
    scss name.to_sym, :layout => false
  end

  get '/modulator/preview/:type' do |type|
    mf = mf_instance_from_request
    method = "preview_#{type}"
    if mf.respond_to? method
      image = mf.method(method).call
      [image ? 200 : 404, { 'Content-Type' => 'image/gif' }, image]
    else
      not_found "The preview type could not be found"
    end
  end

  get '/modulator/export/font/:type/:face/:hash' do |type, face, hash|
    mf = Metaflop.new({ :out_dir => out_dir, :font_hash => hash, :fontface => face })
    mf.settings = settings.metaflop
    mf.logger = logger
    method = "font_#{type}"
    if mf.respond_to? method
      file = mf.method(method).call
      attachment file[:name]
      file[:data]
    else
      not_found "The font type is not supported"
    end
  end

  get '/:page/partial' do |page|
    mf = mf_instance_from_request
    @font_parameters = mf.font_parameters
    @active_fontface = mf.font_settings.fontface

    mustache page.to_sym, :layout => false
  end

  get '/:page/?:subpage?' do |page, subpage|
    if settings.respond_to? page
      @settings = settings.method(page).call
    end

    unless subpage.nil?
      @subpage = subpage
    end

    mustache page.to_sym
  end

  def out_dir
    session[:id] ||= SecureRandom.urlsafe_base64
    "/tmp/metaflop/#{session[:id]}"
  end

  def mf_instance_from_request(params = params)
    # map all query params
    args = { :out_dir => out_dir }
    (FontParameters::VALID_PARAMETERS_KEYS + FontSettings::VALID_OPTIONS_KEYS).each do |key|
      # query params come in with dashes -> replace by underscores to match properties
      value = params[key.to_s.gsub("_", "-")]

      # whitelist allowed characters
      args[key] = value.delete "^a-zA-Z0-9., " if value && !value.empty?
    end

    mf = Metaflop.new(args)
    mf.settings = settings.metaflop
    mf.logger = logger

    mf
  end

end

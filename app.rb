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
require 'sinatra/namespace'
require 'sinatra/asset_pipeline'
require 'sass'
require 'time'
require 'active_support'
require 'data_mapper' # metagem, requires common plugins too.
require './app/logic_less_slim'
require './app/configuration'
require './lib/metaflop'
require './lib/url'

class App < Sinatra::Application
  include LogicLessSlim
  include Configuration

  before do
    @main_navigation = render_navigation :context => :main
    @meta_navigation = render_navigation :context => :meta
  end

  get '/' do
    slim :news, http_caching: false
  end

  namespace '/modulator' do
    get do
      mf = mf_instance_from_request
      @font_parameters = mf.font_parameters
      @active_fontface = mf.font_settings.fontface

      slim :modulator
    end

    # creates a shortened url for the current params (i.e. font setting)
    get '/font/create' do
      Url.create(:params => params)[:short]
    end

    get '/font/:url' do |url|
      url = Url.first(:short => url)

      if url.nil?
        redirect '/'
      end

      mf = mf_instance_from_request url[:params]
      @font_parameters = mf.font_parameters
      @active_fontface = mf.font_settings.fontface

      slim :modulator
    end

    get '/preview' do
      mf = mf_instance_from_request
      mf.font_preview
    end

    get '/export/font/:type/:face/:hash' do |type, face, hash|
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
  end

  # redirect for legacy short urls
  get '/font/:url' do |url|
    redirect to "/modulator/font/#{url}"
  end

  get '/:page/partial' do |page|
    mf = mf_instance_from_request
    @font_parameters = mf.font_parameters
    @active_fontface = mf.font_settings.fontface

    slim page.to_sym, :layout => false, :http_caching => false
  end

  get %r{/(\w+)/?(\w+)?} do |page, subpage|
    if settings.respond_to? page
      @settings = settings.method(page).call
    end

    unless subpage.nil?
      @subpage = subpage
    end

    slim page.to_sym
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

      if value && !value.empty?
        args[key] = value
      end
    end

    mf = Metaflop.new(args)
    mf.settings = settings.metaflop
    mf.logger = logger

    mf
  end
end

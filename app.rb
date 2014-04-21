#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# encoding: UTF-8
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/simple-navigation'
require 'sinatra/namespace'
require 'sinatra/asset_pipeline'
require 'sass'
require 'active_support'
require 'data_mapper' # metagem, requires common plugins too.
require './app/logic_less_slim'
require './app/configuration'
require './lib/metaflop'
require './lib/url'
require './lib/error'

class App < Sinatra::Application
  include LogicLessSlim
  include Configuration

  before do
    @main_navigation = render_navigation :context => :main
    @meta_navigation = render_navigation :context => :meta
  end

  # redirect trailing slash urls
  get %r{(/.+)/$} do
    url = request.fullpath.
      sub(/\/$/, ''). # trailing slash
      sub(/\/\?/, '?') # slash before query params
    redirect to(url), 301
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
      begin
        mf.font_preview
      rescue Metaflop::Error::Metafont
        metafont_error
      end
    end

    get '/export/font/:type/:face/:hash' do |type, face, hash|
      set_http_cache(hash)

      mf = Metaflop.new({ :out_dir => out_dir, :font_hash => hash, :fontface => face })
      mf.settings = settings.metaflop
      mf.logger = logger
      method = "font_#{type}"
      if mf.respond_to? method
        begin
          file = mf.method(method).call
          attachment file[:name]
          file[:data]
        rescue Metaflop::Error::Metafont
          metafont_error
        end
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

    begin
      slim page.to_sym
    rescue
      not_found
    end
  end

  not_found do
    # don't render the whole page if we want to show a specific
    # error message. this is used for ajax call responses.
    if response.body.empty?
      slim :error_404
    else
      response.body
    end
  end

  error do
    slim :error_500
  end

  helpers do
    def metafont_error
      not_found 'The entered value is out of a valid range. Please correct your parameters.'
    end

    def set_http_cache(content)
      require 'digest/sha1'

      cache_control :public, :must_revalidate, :max_age => 60 * 60
      etag Digest::SHA1.hexdigest(content)
    end
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
      value = params[key.to_s]

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

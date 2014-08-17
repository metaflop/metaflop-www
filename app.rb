#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'sinatra'
require 'active_support'
require './app/lib/configuration'
require './app/lib/metaflop'
require './app/models/url'
require './app/lib/error'

class App < Sinatra::Application
  include Configuration

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
      mf = metaflop_create
      @font_parameters = mf.font_parameters
      @active_fontface = mf.font_settings.fontface

      slim :modulator
    end

    # creates a shortened url for the current params (i.e. font setting)
    get '/font/create' do
      Url.first_or_create(:params => params)[:short]
    end

    get '/font/:url' do |url|
      url = Url.first(:short => url)

      if url.nil?
        redirect '/'
      end

      mf = metaflop_create(url[:params])
      @font_parameters = mf.font_parameters
      @active_fontface = mf.font_settings.fontface

      slim :modulator
    end

    get '/preview' do
      mf = metaflop_create
      begin
        mf.font_preview
      rescue Metaflop::Error::Metafont
        metafont_error
      end
    end

    get '/export/font/:type/:face/:hash' do |type, face, hash|
      set_http_cache(hash)

      mf = metaflop_create({ :out_dir => out_dir, :font_hash => hash, :fontface => face })
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
    mf = metaflop_create
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
    PartyFoul::RacklessExceptionHandler.handle(env['sinatra.error'], env)
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

  def metaflop_create(params = params)
    Metaflop.create(params.merge({ :out_dir => out_dir }), settings.metaflop, logger)
  end
end

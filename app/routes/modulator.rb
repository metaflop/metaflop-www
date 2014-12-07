#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/routes/base'
require './app/lib/metaflop'

module Routes
  class Modulator < Base
    namespace '/modulator' do
      get do
        mf = metaflop_create
        @font_parameters = mf.font_parameters
        @active_fontface = mf.font_settings.fontface
        @settings = settings

        slim :modulator
      end

      # creates a shortened url for the current params (i.e. font setting)
      get '/font/create' do
        Url.first_or_create(params: params)[:short]
      end

      get '/font/:url' do |url|
        url = Url.first(short: url)

        if url.nil?
          redirect '/'
        end

        mf = metaflop_create(url[:params])
        @font_parameters = mf.font_parameters
        @active_fontface = mf.font_settings.fontface
        @settings = settings

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

        url = Url.first(short: hash)
        invalid_font_hash_error unless url

        mf = metaflop_create(url[:params].merge(fontface: face, font_hash: hash))

        method = "font_#{type}"
        unsupported_font_type_error unless mf.respond_to?(method)

        begin
          file = mf.method(method).call
          attachment file[:name]
          file[:data]
        rescue Metaflop::Error::Metafont
          metafont_error
        end
      end

      get '/:page/partial' do |page|
        mf = metaflop_create
        @font_parameters = mf.font_parameters
        @active_fontface = mf.font_settings.fontface

        slim page, layout: false, http_caching: false
      end
    end

    helpers do
      def metafont_error
        not_found 'The entered value is out of a valid range. Please correct your parameters.'
      end

      def invalid_font_hash_error
        not_found 'The provided font hash could not be found.'
      end

      def unsupported_font_type_error
        not_found "The font type is not supported"
      end
    end

    def out_dir
      session[:id] ||= SecureRandom.urlsafe_base64
      "/tmp/metaflop/#{session[:id]}"
    end

    def metaflop_create(params = params)
      Metaflop.create(params.merge({ out_dir: out_dir }), settings.metaflop, logger)
    end
  end
end

require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'mustache/sinatra'
require 'fileutils'
require './metaflop'

class App < Sinatra::Base

    configure do
        require './views/layout'
        register Mustache::Sinatra

        set :mustache, {
            :views => './views',
            :templates => './views'
        }

        mime_type :otf, 'font/opentype'

        enable :sessions
    end

    configure :development do
        register Sinatra::Reloader
        set :logging, :true
    end


    get '/' do
        session[:id] ||= SecureRandom.urlsafe_base64

        mf_args = Metaflop.new.mf_args
        @ranges = mf_args[:ranges]
        @defaults = mf_args[:values]
        @defaults.each_key { |key| @defaults[key] = @defaults[key][:clean] }

        mustache :index
    end

    get '/assets/css/:name.scss' do |name|
        content_type :css
        scss name.to_sym, :layout => false
    end

    get '/preview/:type' do |type|
        # map all query params
        args = { :out_dir => "/tmp/metaflop/#{session[:id]}" }
        Metaflop::VALID_OPTIONS_KEYS.each do |key|
            # query params come in with dashes -> replace by underscores to match properties
            value = params[key.to_s.gsub("_", "-")]

            # whitelist allowed characters
            args[key] = value.delete "^a-zA-Z0-9., " if value && !value.empty?
        end

        mf = Metaflop.new(args)
        method = "preview_#{type}"
        if mf.respond_to? method
            image = mf.method(method).call
            [image ? 200 : 404, { 'Content-Type' => 'image/gif' }, image]
        else
            [404, { 'Content-Type' => 'text/html' }, "The preview type could not be found"]
        end
    end

    get '/font/:type' do |type|
        mf = Metaflop.new(:out_dir => "/tmp/metaflop/#{session[:id]}")
        method = "font_#{type}"
        if mf.respond_to? method
            attachment 'metaflop.otf'
            file = mf.method(method).call
        else
            [404, { 'Content-Type' => 'text/html' }, "The font type is not supported"]
        end
    end

end

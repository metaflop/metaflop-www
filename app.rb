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
require 'sass'
require 'mustache/sinatra'
require 'fileutils'
require 'time'
require './metaflop'

class App < Sinatra::Application

    configure do
        register Sinatra::ConfigFile
        config_file './config.yml'

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
    end

    configure :development do
        register Sinatra::Reloader
    end

    configure :production do
        # logging
        log_dir = "log/rack/"
        Dir.mkdir(log_dir) unless Dir.exist? log_dir
        logger = File.new("#{log_dir}#{Time.new.iso8601}.log", 'w+')
        $stderr.reopen(logger)
        $stdout.reopen(logger)
    end


    get '/' do
        mf_args = mf_instance_from_request.mf_args
        @ranges = mf_args[:ranges]
        @defaults = mf_args[:values]

        mustache :index
    end

    get '/assets/css/:name.scss' do |name|
        content_type :css
        scss name.to_sym, :layout => false
    end

    get '/preview/:type' do |type|
        mf = mf_instance_from_request
        method = "preview_#{type}"
        if mf.respond_to? method
            image = mf.method(method).call
            [image ? 200 : 404, { 'Content-Type' => 'image/gif' }, image]
        else
            [404, { 'Content-Type' => 'text/html' }, "The preview type could not be found"]
        end
    end

    get '/font/:type' do |type|
        mf = Metaflop.new(:out_dir => out_dir)
        mf.settings = settings.metaflop
        mf.logger = logger
        method = "font_#{type}"
        if mf.respond_to? method
            attachment 'Bespoke-Regular.otf'
            file = mf.method(method).call
        else
            [404, { 'Content-Type' => 'text/html' }, "The font type is not supported"]
        end
    end

    get '/:page' do |page|
        mustache page.to_sym, :layout => false
    end

    def out_dir
        session[:id] ||= SecureRandom.urlsafe_base64
        "/tmp/metaflop/#{session[:id]}"
    end

    def mf_instance_from_request
        # map all query params
        args = { :out_dir => out_dir }
        Metaflop::VALID_OPTIONS_KEYS.each do |key|
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

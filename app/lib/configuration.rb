#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# configuration for the sinatra app
module Configuration
  def self.included(base)
    base.extend(BaseMethods)
    base.extend(ConfigurationMethods)
  end

  module BaseMethods
    def configure_all
      configure do
        application_root

        sinatra_namespace

        enable :sessions
        enable :logging

        dot_env
        config
        navigation
        tmp_dir
        asset_pipeline
        views
        database
      end

      configure :development do
        require 'pry'

        sinatra_reloader
        better_errors

        # get rid of rack security warning (only for dev)
        set :session_secret, 'pknrgX12iULq0CocY2GBpw'
      end

      configure :production do
        file_logging
        error_reporting
      end
    end

    def configure_root_application
      application_root
      asset_pipeline
      config
    end
  end

  module ConfigurationMethods
    def application_root
      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end

    def sinatra_namespace
      require 'sinatra/namespace'
      register Sinatra::Namespace
    end

    def dot_env
      require 'dotenv'
      Dotenv.load
    end

    def config
      require 'sinatra/config_file'
      register Sinatra::ConfigFile
      config_file [
        './config/config.yml',
        './config/metafonts.yml',
        './config/showcases.yml',
        './config/database.yml'
      ]
    end

    def navigation
      require 'sinatra/simple-navigation'
      register Sinatra::SimpleNavigation

      before do
        @main_navigation = render_navigation(context: :main)
        @meta_navigation = render_navigation(context: :meta)

        main_navigation = render_navigation(context: :main, renderer: :json, as_hash: true)
        meta_navigation = render_navigation(context: :meta, renderer: :json, as_hash: true)

        @navigation_item_exists = (main_navigation + meta_navigation).any? { |item| item[:selected] }
      end
    end

    def asset_pipeline
      require 'sinatra/asset_pipeline'

      set :assets_css_compressor, :sass
      set :assets_js_compressor, :uglifier
      set :assets_precompile, %w(app.js app.css *.png *.jpg *.gif *.svg *.eot *.ttf *.woff *.woff2 *.cur *.swf)
      register Sinatra::AssetPipeline
    end

    def views
      require 'sass'
      require 'slim/logic_less'

      set :views, './app/views'
      require './app/views/layout'

      Slim::Engine.set_options pretty: true

      mime_type :otf, 'font/opentype'

      require './app/lib/logic_less_slim'
      include LogicLessSlim
    end

    def tmp_dir
      # setup the tmp dir where the generated fonts go
      require 'fileutils'
      tmp_dir = '/tmp/metaflop'
      FileUtils.rm_rf(tmp_dir)
      Dir.mkdir(tmp_dir)
    end

    def database
      require 'sequel'
      @connection ||= Sequel.connect(
        adapter:  settings.db[:adapter],
        host:     settings.db[:host],
        database: settings.db[:database],
        user:     settings.db[:username],
        password: settings.db[:password]
      )
    end

    def sinatra_reloader
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload '**/*.rb'
      dont_reload '**/*spec.rb'
    end

    def better_errors
      require 'better_errors'
      use BetterErrors::Middleware
      # set the application root in order to abbreviate filenames
      # within the application
      BetterErrors.application_root = settings.root
    end

    def error_reporting
      # the SENTRY_DSN environment variable needs to be set (-> .env)
      require 'raven'
      use Raven::Rack
    end

    def file_logging
      require 'fileutils'
      require 'time'

      log_dir = File.join(settings.root, 'log/rack/')
      FileUtils.mkdir_p(log_dir) unless Dir.exist? log_dir
      logger = File.new("#{log_dir}#{Time.new.iso8601}.log", 'w+')
      $stderr.reopen(logger)
      $stdout.reopen(logger)
    end
  end
end

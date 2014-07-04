#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

# configuration for the sinatra app
module Configuration
  # delegate to the base class (the one that includes this module)
  # which is a sinatra application class and defines all the used
  # methods as 'configure', 'register' etc.
  # this way, we can define the configure blocks as if we were
  # inside a sinatra class
  def self.method_missing(method, *args, &block)
    @base.send(method, *args, &block)
  end

  def self.included(base)
    @base = base

    global
    development
    production
  end

  def self.global
    configure do
      require 'dotenv'
      Dotenv.load

      register Sinatra::ConfigFile
      config_file ['./config/config.yml', './config/db.yml']

      register Sinatra::SimpleNavigation

      register Sinatra::Namespace

      set :assets_css_compressor, :sass
      set :assets_js_compressor, :uglifier
      set :assets_precompile, %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff *.cur)
      register Sinatra::AssetPipeline

      # gzip compression
      use Rack::Deflater

      # setup the tmp dir where the generated fonts go
      tmp_dir = "/tmp/metaflop"
      FileUtils.rm_rf(tmp_dir)
      Dir.mkdir(tmp_dir)

      # views
      set :views, self.root + '/app/views'
      require './app/views/layout'

      Slim::Engine.set_default_options :pretty => true

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
  end

  def self.development
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload '**/*.rb'
      dont_reload '**/*spec.rb'

      require 'better_errors'
      use BetterErrors::Middleware
      # set the application root in order to abbreviate filenames
      # within the application
      BetterErrors.application_root = self.root

      # get rid of rack security warning (only for dev)
      set :session_secret, 'pknrgX12iULq0CocY2GBpw'
    end
  end

  def self.production
    configure :production do
      # logging
      require 'time'
      log_dir = "log/rack/"
      Dir.mkdir(log_dir) unless Dir.exist? log_dir
      logger = File.new("#{log_dir}#{Time.new.iso8601}.log", 'w+')
      $stderr.reopen(logger)
      $stdout.reopen(logger)

      # error reporting
      require 'party_foul'
      PartyFoul.configure do |config|
        config.oauth_token = ENV['PARTY_FOUL_OAUTH_TOKEN']
        config.owner = 'metaflop'
        config.repo = 'metaflop-www'
        config.title_prefix = environment
        config.additional_labels = -> (exception, env) do
          if env["HTTP_HOST"] =~ /^test\./
            ['staging']
          else
            ['production']
          end
        end
      end
      use PartyFoul::Middleware
    end
  end
end

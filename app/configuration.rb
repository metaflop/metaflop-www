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
      register Sinatra::ConfigFile
      config_file ['./config.yml', './db.yml']

      register Sinatra::SimpleNavigation

      register Sinatra::Namespace

      # setup the tmp dir where the generated fonts go
      tmp_dir = "/tmp/metaflop"
      FileUtils.rm_rf(tmp_dir)
      Dir.mkdir(tmp_dir)

      require './views/layout'

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
      register Sinatra::Reloader
      also_reload '**/*.rb'
      dont_reload '**/*spec.rb'
    end
  end

  def self.production
    configure :production do
      # logging
      log_dir = "log/rack/"
      Dir.mkdir(log_dir) unless Dir.exist? log_dir
      logger = File.new("#{log_dir}#{Time.new.iso8601}.log", 'w+')
      $stderr.reopen(logger)
      $stdout.reopen(logger)
    end
  end
end

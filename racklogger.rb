require 'rack'

module RackLogger
    attr_accessor :logger

    def logger
        @logger || Rack::NullLogger.new
    end
end

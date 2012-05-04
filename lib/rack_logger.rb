#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require 'rack'

module RackLogger
  attr_accessor :logger

  def logger
    @logger || Rack::NullLogger.new
  end
end

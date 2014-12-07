#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/lib/configuration'
require './app/lib/error'

module Routes
  class Base < Sinatra::Base
    include Configuration

    not_found do
      # don't render the whole page if we want to show a specific
      # error message. this is used for ajax call responses.
      if response.body.empty?
        halt slim :error_404
      else
        halt response.body
      end
    end

    error do
      PartyFoul::RacklessExceptionHandler.handle(env['sinatra.error'], env)
      halt slim :error_500
    end

    helpers do
      def set_http_cache(content)
        require 'digest/sha1'

        cache_control :public, :must_revalidate, max_age: 60 * 60
        etag Digest::SHA1.hexdigest(content)
      end
    end
  end
end

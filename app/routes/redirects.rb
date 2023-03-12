#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/routes/base'

module Routes
  class Redirects < Base
    # redirect modulator legacy short urls
    get '/font/:url' do |url|
      redirect to("/modulator/font/#{url}"), 301
    end

    get '/metafonts' do
      redirect to('/metafonts/adjuster'), 303
    end

    get '/showcases' do
      redirect to('/showcases/sum_of_parts'), 303
    end

    # redirect trailing slash urls
    get %r{(/.+)/} do
      url = request.fullpath.
        sub(/\/$/, ''). # trailing slash
        sub(/\/\?/, '?') # slash before query params
      redirect to(url), 301
    end
  end
end

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './app/routes/base'

module Routes
  class Pages < Base
    get %r{/(\w+)/?(\w+)?} do |page, subpage|
      if settings.respond_to? page
        @settings = settings.method(page).call
      end

      @subpage = subpage

      begin
        slim page
      rescue
        not_found
      end
    end
  end
end

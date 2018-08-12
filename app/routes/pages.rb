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
      return not_found unless @navigation_item_exists

      # not all pages have settings
      @settings = settings.method(page).call if settings.respond_to?(page)
      @subpage = subpage

      begin
        slim page
      rescue
        not_found
      end
    end
  end
end

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/rack_settings'
require './lib/slideshow_page'

module ShowoffPage
  include RackSettings
  include SlideshowPage

  def single(name)
    all.find { |x| x[:title] == name }
  end

  def all
    pages = settings.to_a.map do |x|
      {
        :title => x[0],
        :description => x[1]["description"],
        :images => x[1]["images"].map do |img|
          {
            :url => "/img/#{page_name}/#{img[0]}",
            :title => img[1]
          }
        end,
        :subimages => (x[1]["subimages"] || []).map.with_index do |img, i|
          {
            :url => "/img/#{page_name}/#{img[0]}",
            :short => img[1],
            :first => i == 0
          }
        end
      }
    end
    current(pages)["active"] = true
    pages
  end

  def current(pages = nil)
    pages ||= all
    unless @subpage.nil?
      pages.find { |x| x[:title] == @subpage } 
    else
      pages[0]
    end
  end
end

#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

require './lib/rack_settings'

module ShowoffPage
  include RackSettings

  def js
    ['/js/basic-jquery-slider.min.js', "/js/showoff-page.js"]
  end

  def css
    ['/assets/css/basic-jquery-slider.scss']
  end

  def single(name)
    all.find { |x| x[:title] == name }
  end

  def all
    pages = settings.to_a.map do |x|
      {
        :title => x[0],
        :description => x[1]["description"],
        :images => x[1]["images"].map { |img| "/img/#{page_name}/#{img}" },
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

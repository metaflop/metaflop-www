#
# metaflop - web interface
# © 2012 by alexis reigel
# www.metaflop.com
#
# licensed under gpl v3
#

module SlideshowPage
  def js
    ['/js/basic-jquery-slider.min.js', "/js/slideshow-page.js"]
  end

  def css
    ['/assets/css/basic-jquery-slider.scss']
  end
end
